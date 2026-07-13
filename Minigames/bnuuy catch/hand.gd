extends CharacterBody2D

func _ready():
	visible = false

func slam(x:float):
	if $Timer.time_left > 0:
		return
	position = Vector2(x, -100)

	$Sprite2D.flip_h = x - %Bnuuy.position.x > 0

	$Timer.start(0.2)
	visible = true
	speed = 100
	accel = 20

var speed:float
var accel:float
func _physics_process(delta):
	speed += accel*delta
	var result = move_and_collide(Vector2.DOWN * speed)
	if result:
		var struck = result.get_collider()
		if struck.name == &"Bnuuy":
			struck.squish()
		accel = 0
		speed = 0
		Sfx.play_sfx("punch")
		Minigame.get_game(self).screenshake()
