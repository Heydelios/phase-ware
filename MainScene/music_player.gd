class_name MusicPlayer
extends AudioStreamPlayer

## Interactive, beat-synchronised music player.
##
## Wraps an [AudioStreamInteractive] built from the theme slots below. Tempo
## changes are handled by swapping to a clip recorded at the target tempo (never
## by real-time pitch shifting), and beat/bar timing is read straight from the
## audio output clock so it never drifts.
##
## The game is meant to follow this player, not the other way around: connect to
## [signal beat] / [signal bar], or poll [method beat_duration].

## Emitted once per beat, carrying the running beat index within the current clip.
signal beat(index: int)
## Emitted on the first beat of every bar, carrying the running bar index.
signal bar(index: int)

@export_group("Themes")
@export var prelude: AudioStream
@export var main: AudioStream
@export var loss: AudioStream
@export var win: AudioStream
@export var speed_up: AudioStream

@export_group("Timing")
## BPM applied to any assigned stream that has no BPM metadata of its own.
@export var default_bpm := 80.0
## Beats per bar, used both for the [signal bar] signal and bar-aligned transitions.
@export var beats_per_bar := 4
## Cross-fade length (in beats) for runtime transitions between clips.
@export var fade_beats := 4.0

# --- Clip registry (name <-> clip index in the interactive stream) -----------
var _names: Array[StringName] = []
var _index := {}

# --- Beat clock state --------------------------------------------------------
var _pb: AudioStreamPlaybackInteractive
var _cur_clip := -1
var _clip_bpm := 80.0
var _clip_len := 0.0
var _clip_beats := 0 # total beats in the current clip, for detecting loop wraps
var _beat_index := -1 # last beat emitted within the current clip run
var _loop_offset := 0 # beats contributed by completed loops of the current clip
var _last_pos := 0.0


func _ready() -> void:
	bus = &"Music"
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
	if clip != _cur_clip:
		_enter_clip(clip, pos)

	# A loop restart makes the position jump back to (near) zero; carry the beats
	# from the completed loop forward so the running index stays continuous.
	if _clip_len > 0.0 and pos < _last_pos - _clip_len * 0.5:
		_loop_offset += _clip_beats
	_last_pos = pos

	var target := _loop_offset + int(pos * _clip_bpm / 60.0)
	while _beat_index < target:
		_beat_index += 1
		if _beat_index % beats_per_bar == 0:
			bar.emit(_beat_index / beats_per_bar)
		beat.emit(_beat_index)


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


## Seconds per beat at the current tempo.
func beat_duration() -> float:
	return 60.0 / _clip_bpm


# --- Setup -------------------------------------------------------------------

func _build_stream() -> void:
	var si := AudioStreamInteractive.new()
	_names.clear()
	_index.clear()

	# name, stream, loops?, auto-advance target (&"" = none)
	var nexts := {}
	_consider(&"prelude", prelude, false, &"main", nexts)
	_consider(&"main", main, true, &"", nexts)
	_consider(&"loss", loss, true, &"", nexts)
	_consider(&"win", win, true, &"", nexts)
	_consider(&"speed_up", speed_up, false, &"main", nexts)
	# Runtime-swappable slot for per-minigame music; seeded with main so it is
	# never empty (see play_minigame_music).
	_consider(&"minigame", main, true, &"", nexts)

	si.clip_count = _names.size()
	for i in _names.size():
		si.set_clip_name(i, _names[i])
		si.set_clip_stream(i, _stream_for(_names[i]))

	# Default rule for every switch: wait for the next bar, then cross-fade to
	# the start of the destination. FADE_AUTOMATIC picks a sensible fade shape.
	si.add_transition(
		AudioStreamInteractive.CLIP_ANY, AudioStreamInteractive.CLIP_ANY,
		AudioStreamInteractive.TRANSITION_FROM_TIME_NEXT_BAR,
		AudioStreamInteractive.TRANSITION_TO_TIME_START,
		AudioStreamInteractive.FADE_AUTOMATIC, fade_beats)

	for i in _names.size():
		var next: StringName = nexts.get(_names[i], &"")
		if next != &"" and _index.has(next):
			si.set_clip_auto_advance(i, AudioStreamInteractive.AUTO_ADVANCE_ENABLED)
			si.set_clip_auto_advance_next_clip(i, _index[next])

	# The intro should hand off to the loop seamlessly at its end, not cross-fade
	# on a bar, so override the default rule for prelude -> main.
	if _index.has(&"prelude") and _index.has(&"main"):
		si.add_transition(
			_index[&"prelude"], _index[&"main"],
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
	# Fire the beat we land on (the downbeat for a start-aligned transition)
	# without replaying every beat that precedes an offset entry point.
	_beat_index = int(pos * _clip_bpm / 60.0) - 1


func _stream_bpm(s: AudioStream) -> float:
	if s:
		var b = s.get("bpm")
		if b != null and float(b) > 0.0:
			return float(b)
	return default_bpm
