extends Minigame

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		%Hand.slam(event.position.x)
