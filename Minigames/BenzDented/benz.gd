extends TextureRect

var start_pos := Vector2(-100,514.0)
var x_vel : float = 650
var is_braking := false
var is_stopped := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = start_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Minigame.get_game(self).game_ended:
		return

	position.x += x_vel*delta

	if position.x > %ParkingZone.position.x + %ParkingZone.size.x - size.x:
		#Play loss anim crash
		%BenzBroke.visible = true
		%AnimPlayer.play("loss")
		self_modulate = Color(1,1,1,0)
		Minigame.lose_game(self)

	if is_braking:
		x_vel *= .95
		if x_vel < 5:
			x_vel = 0
			stop_check()

func stop_check() -> void:
	if position.x > %ParkingZone.position.x:
		#play win anim park success
		%AnimPlayer.play("win")
		Minigame.win_game(self)
	else:
		Minigame.lose_game(self)
		%AnimPlayer.play("loss_alt")
		#play_loss anim fail park (early)

func _unhandled_input(event):
	if Minigame.get_game(self).game_ended:
		return
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("spacebar"):
			is_braking = true
