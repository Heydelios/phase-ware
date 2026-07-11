extends Minigame

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	Events.minigame_won.emit()
	queue_free()

func _unhandled_input(event):
	pass
