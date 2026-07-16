extends AudioStreamPlayer

const BASE_TEMPO = 80.0
@export_range(BASE_TEMPO, 180, 10, "suffix:bpm") var tempo:float = BASE_TEMPO:
	set(val):
		tempo = val
		set_bpm(val)

@export var prelude:AudioStream:
	set(val):
		prelude = val
		setup_stream()
@export var main:AudioStream:
	set(val):
		main = val
		setup_stream()

func get_pitch_shift_effect() -> AudioEffectPitchShift:
	var bus_idx = AudioServer.get_bus_index(bus)
	for i in range(AudioServer.get_bus_effect_count(bus_idx)):
		var eff = AudioServer.get_bus_effect(bus_idx, i)
		if eff is AudioEffectPitchShift:
			return eff
	var out = AudioEffectPitchShift.new()
	print("warn: creating new bus effect: %s" % out)
	AudioServer.add_bus_effect(bus_idx, out)
	return out

signal beat
signal bar

var pitch:AudioEffectPitchShift
func set_bpm(bpm:float):
	pitch_scale = bpm / BASE_TEMPO
	print(pitch_scale)
	if pitch:
		pitch.pitch_scale = 1.0 / pitch_scale # yes, it's confusing they're both called "pitch_scale"

enum {PRELUDE, MAIN}
func set_stream_active(i: int):
	for j in range(stream.stream_count):
		stream.set_sync_stream_volume(j, 0 if j==i else -60)

func setup_stream() -> void:
	stream = AudioStreamSynchronized.new()
	stream.stream_count = 2
	stream.set_sync_stream(PRELUDE, prelude)
	stream.set_sync_stream(MAIN, main)

func _ready() -> void:
	bus = &"Music"
	pitch = get_pitch_shift_effect()
	set_stream_active(PRELUDE)
	set_bpm(80)
	if not Engine.is_editor_hint():
		play()

var bar_count:int
func _on_bar():
	bar_count += 1
	bar.emit()
	if bar_count == 4:
		set_stream_active(MAIN)
		bar_count = 0
		tempo += 10
		play()


var beat_count:int
func _on_beat():
	beat_count += 1
	beat.emit()
	if beat_count == 4:
		beat_count = 0
		_on_bar()

var beat_cumer = Cumer.new(BASE_TEMPO/60, _on_beat)
func _process(delta: float) -> void:
	beat_cumer.add(delta * pitch_scale)
