class_name Clock
extends TextureRect

var ticks:int = 0
func tick(amount:int=1):
	if ticks < 12 and ticks + amount >= 12:
		Events.time_over.emit()
	ticks += amount
	match ticks:
		9:
			Sfx.play_sfx("tick")
		10:
			Sfx.play_sfx("tock")
		11:
			Sfx.play_sfx("tick")
		12:
			return

	texture = (texture as HandyAtlas)
	texture.add_xy(1,0)

	if ticks == 3:
		Music.offbeat.connect(tick)

func ring() -> void:
	while true:
		await get_tree().create_timer(60.0/12).timeout
		texture.cycle_x(1,11,13)

func _ready() -> void:
	texture = (texture as HandyAtlas) # tells the editor what type it is and also throws an error if type mismatch
	texture.region.size = texture.atlas.get_size() / Vector2(14,1)
	size = texture.region.size * 4
	texture.set_xy(0,0)
	Music.beat.connect(tick)
