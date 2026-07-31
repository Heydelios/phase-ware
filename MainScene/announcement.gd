extends Control

var is_boss : bool = false
var duration : float = 1

func _ready() -> void:
	#%AnimationPlayer.play("pop_in")
	if is_boss:
		%Label.text = "BOSS STAGE"

	visible = true
	get_tree().create_timer(duration-0.2).timeout.connect(exit_anim)

func exit_anim() -> void:
	%AnimationPlayer.play("end")
	get_tree().create_timer(0.2).timeout.connect(queue_free)
