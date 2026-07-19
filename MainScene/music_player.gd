class_name MusicPlayer
extends AudioStreamPlayer

var music = preload("res://audio/music/master-80bpm.ogg")

enum {PRELUDE, PRELUDE_2, MAIN, MAIN_2, WIN, LOSS, SPEEDUP}
var current_section:=PRELUDE
var next_section:int

signal section_played
signal beat ## note: this doesn't start working until a couple of seconds into the game
signal offbeat

var beat_cumer:Cumer

func beat_length() -> float:
	return 60.0 / stream.bpm

func section_length() -> float:
	return beat_length() * section_beats

const section_beats = 8.0
func _set_section(i:int, offset:float=0):
	current_section = i
	play(section_length() * i + offset)
	beat_cumer.reset()
	beat_cumer.add(offset)

func _on_beat():
	print("beat")
	beat.emit()
	await get_tree().create_timer(beat_length()/2).timeout
	offbeat.emit()

func _on_section_done():
	if current_section == PRELUDE or current_section == MAIN:
		current_section += 1
	else:
		_set_section(next_section)

func _on_win():
	next_section=WIN
func _on_lose():
	next_section=LOSS

func _ready():
	stream = music
	stream.bpm = 80
	stream.bar_beats = 4
	print("%f = %f" % [stream.get_length(), beat_length() * section_beats * 7])
	beat_cumer = Cumer.new(stream.bpm/60, _on_beat)
	next_section = SPEEDUP
	Events.minigame_won.connect(_on_win)
	Events.minigame_lost.connect(_on_lose)
	play()

func _process(delta:float):
	beat_cumer.add(delta)
	var pb = get_stream_playback()
	if not pb or pb.get_playback_position() >= section_length() * (current_section+1):
		_on_section_done()
