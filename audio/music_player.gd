extends AudioStreamPlayer

var loss = preload("res://audio/music/loss-80bpm.ogg")
var main = preload("res://audio/music/main-80bpm.ogg")
var prelude = preload("res://audio/music/prelude-80bpm.ogg")
var win = preload("res://audio/music/win-80bpm.ogg")
var speedup = preload("res://audio/music/speed_up-80bpm.ogg")

var next_section:AudioStream

signal section_played
signal beat ## note: this doesn't start working until a couple of seconds into the game
signal offbeat

var beat_cumer:Cumer

func beat_length() -> float:
	return 60.0 / stream.bpm

func section_length() -> float:
	return beat_length() * section_beats

const section_beats = 8.0
func _set_section(section:AudioStream):
	stream=section
	stream.bpm = 80
	stream.bar_beats = 4
	play()
	if beat_cumer:
		beat_cumer.reset()

func _on_beat():
	beat.emit()
	await get_tree().create_timer(beat_length()/2).timeout
	offbeat.emit()

func _on_section_done():
	_set_section(next_section)
	next_section = main
	section_played.emit()

func speed_up(speed:float):
	pitch_scale = speed
	await play_section(speedup)

func play_section(section:AudioStream):
	_set_section(section)
	await get_tree().create_timer(section.get_length() / pitch_scale).timeout

func _on_win():
	next_section = win
func _on_loss():
	next_section = loss

func _ready():
	_set_section(prelude)
	beat_cumer = Cumer.new(stream.bpm/60, _on_beat)
	Events.minigame_won.connect(_on_win)
	Events.minigame_lost.connect(_on_loss)
	var pb = get_stream_playback()
	while pb == null:
		await get_tree().create_timer(1).timeout
		play()
		pb = get_stream_playback()

func _process(delta:float):
	beat_cumer.add(delta*pitch_scale)
	var pb = get_stream_playback()
	if not pb:
		_on_section_done()
	else:
		var time_left = stream.get_length() - pb.get_playback_position()
		if time_left < 0:
			_on_section_done()
			print("finished section with %f overage" % -time_left)
