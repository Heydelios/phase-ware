extends Node

var intro_duration : float = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(intro_duration).timeout
	Events.intro_end.emit()
	queue_free()
	pass # Replace with function body.

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("spacebar"):
			Events.intro_end.emit()
			queue_free()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
