extends TextureRect

var rotation_dir : float = 0
var rotation_speed : float = 2
var coef := PI/90


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation_degrees = randf_range(-30,30)
	rotation_dir = [1, -1].pick_random()
	Events.time_over.connect(loss_anim)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Minigame.get_game(self).game_ended:
		return

	var speed_factor : float = max(0.2, cos(rotation_degrees*coef))
	rotation_degrees += rotation_dir * rotation_speed * speed_factor
	if abs(rotation_degrees) > 45:
		rotation_dir *= -1

func loss_anim() -> void:
	if Minigame.get_game(self).game_ended:
		return
	%AnimationPlayer.play("loss")

