class_name MusicPlayer
extends AudioStreamPlayer

## Interactive, beat-synchronised music player.
##
## Wraps an [AudioStreamInteractive] built from the theme slots below. Tempo
## changes are handled by swapping to a clip recorded at the target tempo (never
## by real-time pitch shifting), and beat/bar timing is read straight from the
## audio output clock so it never drifts.
##
## The game is meant to follow this player, not the other way around: the beat
## grid is published on the global Events bus (Events.beat / Events.bar /
## Events.half_beat), or poll [method beat_duration].

# Fires whenever the active clip changes; drives play_music()'s awaiting.
signal _clip_started(clip_name: StringName)

## Theme identifiers for [method play_music], e.g. play_music(MusicPlayer.WIN).
enum {PRELUDE, MAIN, LOSS, WIN, SPEED_UP, MINIGAME}
const _THEME_NAME := {
	PRELUDE: &"prelude",
	MAIN: &"main",
	LOSS: &"loss",
	WIN: &"win",
	SPEED_UP: &"speed_up",
	MINIGAME: &"minigame",
}

# Themes, loaded by deterministic name. The "-80bpm" set is the base tempo;
# faster-tempo variants would slot in here as a tempo ladder later.
var prelude := preload("res://audio/music/prelude-80bpm.ogg")
var main := preload("res://audio/music/main-80bpm.ogg")
var loss := preload("res://audio/music/loss-80bpm.ogg")
var win := preload("res://audio/music/win-80bpm.ogg")
var speed_up := preload("res://audio/music/speed_up-80bpm.ogg")

@export_group("Timing")
## BPM applied to any assigned stream that has no BPM metadata of its own.
@export var default_bpm := 80.0
## Beats per bar, used both for the Events.bar signal and bar-aligned transitions.
@export var beats_per_bar := 4
## Cross-fade length (in beats) for runtime transitions between clips.
@export var fade_beats := 4.0

# --- Clip registry (name <-> clip index in the interactive stream) -----------
var _names: Array[StringName] = []
var _index := {}
var _loops := {} # name -> bool: whether the clip loops (vs. a one-shot jingle)

# --- Beat clock state --------------------------------------------------------
# The grid is tracked at half-beat resolution (pulses); whole beats and bars are
# derived from it, so double-time consumers and beat consumers stay aligned.
var _pb: AudioStreamPlaybackInteractive
var _cur_clip := -1
var _clip_bpm := 80.0
var _clip_len := 0.0
var _clip_beats := 0 # total beats in the current clip, for detecting loop wraps
var _pulse_index := -1 # last half-beat emitted within the current clip run
var _loop_offset := 0 # half-beats contributed by completed loops of the clip
var _last_pos := 0.0


func _ready() -> void:
	bus = &"Music"
	pitch_scale = 1.3
	_build_stream()
	if not Engine.is_editor_hint():
		play()


func _process(_delta: float) -> void:
	if _pb == null:
		if playing:
			var p := get_stream_playback()
			if p is AudioStreamPlaybackInteractive:
				_pb = p
		if _pb == null:
			return

	var pos := _audio_pos()
	var clip := _pb.get_current_clip_index()
	if Engine.get_process_frames() % 30 == 0:
		print("DBG pos=%.3f rawpos=%.3f clip=%d pulse=%d playing=%s" % [pos, get_playback_position(), clip, _pulse_index, str(playing)])
	if clip != _cur_clip:
		_enter_clip(clip, pos)

	# A loop restart makes the position jump back to (near) zero; carry the beats
	# from the completed loop forward so the running index stays continuous.
	if _clip_len > 0.0 and pos < _last_pos - _clip_len * 0.5:
		_loop_offset += _clip_beats * 2
	_last_pos = pos

	# Advance the half-beat grid, deriving whole beats and bars from even pulses.
	var target := _loop_offset + int(pos * _clip_bpm / 60.0 * 2.0)
	while _pulse_index < target:
		_pulse_index += 1
		Events.half_beat.emit(_pulse_index)
		if _pulse_index % 2 == 0:
			var b := _pulse_index / 2
			if b % beats_per_bar == 0:
				Events.bar.emit(b / beats_per_bar)
			Events.beat.emit(b)


# --- Public API --------------------------------------------------------------

## Request a switch to a named theme. The transition table decides when (next
## bar) and how (cross-fade) it actually happens, so this is safe to call at any
## time. Unknown names are ignored with a warning.
func transition_to(clip_name: StringName) -> void:
	if not _index.has(clip_name):
		push_warning("MusicPlayer: no clip named '%s'" % clip_name)
		return
	if _pb:
		_pb.switch_to_clip_by_name(clip_name)


## Switch to a theme, e.g. `await play_music(MusicPlayer.WIN)`. The await
## resolves at the musically-meaningful moment: for one-shot jingles (win, loss,
## speed_up) once the jingle has finished and playback has handed back to the
## main loop; for looping themes as soon as the theme starts. Fire-and-forget
## (no await) is fine too.
func play_music(theme: int) -> void:
	var clip_name: StringName = _THEME_NAME.get(theme, &"")
	if not _index.has(clip_name):
		push_warning("MusicPlayer: theme %d is not available" % theme)
		return
	if current_clip_name() != clip_name:
		transition_to(clip_name)
		while current_clip_name() != clip_name:
			await _clip_started
	if not _loops.get(clip_name, true):
		# One-shot: wait for it to finish and auto-advance back to the main loop.
		while current_clip_name() == clip_name:
			await _clip_started


## Play per-minigame music. Passing null (no dedicated track) falls back to the
## main theme, which callers can dim via the Music bus volume.
func play_minigame_music(s: AudioStream) -> void:
	if s == null:
		transition_to(&"main")
		return
	if not _index.has(&"minigame"):
		push_warning("MusicPlayer: no minigame clip slot available")
		return
	_prepare_stream(s, true)
	(stream as AudioStreamInteractive).set_clip_stream(_index[&"minigame"], s)
	transition_to(&"minigame")


## Name of the clip currently playing, or &"" before playback starts.
func current_clip_name() -> StringName:
	if _pb:
		var i := _pb.get_current_clip_index()
		if i >= 0 and i < _names.size():
			return _names[i]
	return &""


func current_bpm() -> float:
	return _clip_bpm


## Real-time seconds per beat at the current tempo, accounting for pitch_scale
## (which speeds up playback and therefore the beat along with it).
func beat_duration() -> float:
	return 60.0 / _clip_bpm / pitch_scale


# --- Setup -------------------------------------------------------------------

func _build_stream() -> void:
	var si := AudioStreamInteractive.new()
	_names.clear()
	_index.clear()

	# name, stream, loops?, auto-advance target (&"" = none)
	var nexts := {}
	_consider(&"prelude", prelude, false, &"main", nexts)
	_consider(&"main", main, true, &"", nexts)
	# win/loss/speed_up are one-shot jingles that hand back to the main loop.
	_consider(&"loss", loss, false, &"main", nexts)
	_consider(&"win", win, false, &"main", nexts)
	_consider(&"speed_up", speed_up, false, &"main", nexts)
	# Runtime-swappable slot for per-minigame music; seeded with main so it is
	# never empty (see play_minigame_music).
	_consider(&"minigame", main, true, &"", nexts)

	si.clip_count = _names.size()
	for i in _names.size():
		si.set_clip_name(i, _names[i])
		si.set_clip_stream(i, _stream_for(_names[i]))

	# Default rule for a requested switch: on the next beat, cross-fade to the
	# start of the destination. Next-beat (rather than next-bar) keeps win/loss
	# feedback snappy; FADE_AUTOMATIC picks a sensible fade shape.
	si.add_transition(
		AudioStreamInteractive.CLIP_ANY, AudioStreamInteractive.CLIP_ANY,
		AudioStreamInteractive.TRANSITION_FROM_TIME_NEXT_BEAT,
		AudioStreamInteractive.TRANSITION_TO_TIME_START,
		AudioStreamInteractive.FADE_AUTOMATIC, fade_beats)

	for i in _names.size():
		var next: StringName = nexts.get(_names[i], &"")
		if next == &"" or not _index.has(next):
			continue
		si.set_clip_auto_advance(i, AudioStreamInteractive.AUTO_ADVANCE_ENABLED)
		si.set_clip_auto_advance_next_clip(i, _index[next])
		# Hand off seamlessly at the clip's end (intro -> loop, and each one-shot
		# jingle -> back to main) instead of the default cross-fade.
		si.add_transition(
			i, _index[next],
			AudioStreamInteractive.TRANSITION_FROM_TIME_END,
			AudioStreamInteractive.TRANSITION_TO_TIME_START,
			AudioStreamInteractive.FADE_DISABLED, 0.0)

	si.initial_clip = _index.get(&"prelude", 0)
	stream = si


# Streams are looked up by name so the seeded minigame slot shares the main
# resource without needing a second reference.
func _stream_for(clip_name: StringName) -> AudioStream:
	match clip_name:
		&"prelude": return prelude
		&"main", &"minigame": return main
		&"loss": return loss
		&"win": return win
		&"speed_up": return speed_up
	return null


func _consider(clip_name: StringName, s: AudioStream, should_loop: bool,
		next: StringName, nexts: Dictionary) -> void:
	if s == null:
		return
	_prepare_stream(s, should_loop)
	_index[clip_name] = _names.size()
	_names.append(clip_name)
	_loops[clip_name] = should_loop
	nexts[clip_name] = next


# Stamp the beat grid / loop flag onto a stream. Uses get()/set() so it works
# for any AudioStream subtype and silently skips properties it doesn't have.
func _prepare_stream(s: AudioStream, should_loop: bool) -> void:
	var b = s.get("bpm")
	if b != null and float(b) <= 0.0:
		s.set("bpm", default_bpm)
	if s.get("bar_beats") != null:
		s.set("bar_beats", beats_per_bar)
	if s.get("loop") != null:
		s.set("loop", should_loop)


# --- Beat clock helpers ------------------------------------------------------

# Current position within the active clip, corrected for mix buffering and
# output latency. This is the drift-free audio clock the beat grid rides on.
func _audio_pos() -> float:
	var t := get_playback_position()
	t += AudioServer.get_time_since_last_mix()
	t -= AudioServer.get_output_latency()
	return maxf(t, 0.0)


func _enter_clip(clip: int, pos: float) -> void:
	_cur_clip = clip
	var s := (stream as AudioStreamInteractive).get_clip_stream(clip)
	_clip_bpm = _stream_bpm(s)
	_clip_len = s.get_length() if s else 0.0
	_clip_beats = int(round(_clip_len * _clip_bpm / 60.0))
	_loop_offset = 0
	_last_pos = pos
	# Land on the current pulse (the downbeat for a start-aligned transition)
	# without replaying every pulse that precedes an offset entry point.
	_pulse_index = int(pos * _clip_bpm / 60.0 * 2.0) - 1
	var clip_name: StringName = _names[clip] if clip >= 0 and clip < _names.size() else &""
	_clip_started.emit(clip_name)


func _stream_bpm(s: AudioStream) -> float:
	if s:
		var b = s.get("bpm")
		if b != null and float(b) > 0.0:
			return float(b)
	return default_bpm
