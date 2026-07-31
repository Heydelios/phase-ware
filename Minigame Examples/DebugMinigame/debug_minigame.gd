extends Minigame

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("spacebar"):
			Events.minigame_won.emit()
			queue_free()
		if event.pressed and event.is_action_pressed("up"):
			_minigame_loss()

func _minigame_loss() -> void:
	Events.minigame_lost.emit()
	queue_free()
