extends Sprite2D

var sections : int = 16
var start_rot : float = 0
var total_rot : float = 0

var nb_rotations : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.time_over.connect(on_loss)

	position = Vector2(640, 360)
	var cursor_pos := get_local_mouse_position()
	rotation = 0
	rotation += cursor_pos.angle() + start_rot
	start_rot = rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Minigame.get_game(self).game_ended:
		return

	var cursor_pos := get_local_mouse_position()
	rotation += cursor_pos.angle() + start_rot

	if rotation*180/PI > 5*360:
		#insert win_anim
		%Anims.play("success")
		Minigame.win_game(self)
		%LidTex.visible = false

func on_loss() -> void:
	%LidTex.visible = false
	if Minigame.get_game(self).game_ended:
		return
	%Anims.play("failure")
	#play loss_anim
