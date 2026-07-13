extends AudioStreamPlayer
class_name SFX

var sfx = {}

func _add_audio_directory(dir:String):
	for wav in ResTools.list_resources(dir, ".wav"):
		var key = wav.resource_name
		assert(key)
		assert(not sfx.has(key))
		sfx[key] = wav
	for d in ResTools.list_subdirectories(dir):
		_add_audio_directory(d)

func get_playback() -> AudioStreamPlaybackPolyphonic:
	if not has_stream_playback():
		play()
	return get_stream_playback()

func play_sfx(effect_name:String):
	if not sfx.has(effect_name):
		print("Warn: no sfx named %s" % effect_name)
		return
	var pb = get_playback()
	if not pb:
		print("Warn: audio is fucked while attempting to play %s" % effect_name)
		return
	pb.play_stream(sfx[effect_name])

func _ready():
	_add_audio_directory("audio/bitcrushed")
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = 8
