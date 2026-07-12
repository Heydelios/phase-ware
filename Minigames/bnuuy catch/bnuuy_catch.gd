extends Minigame

func _time_over() -> void:
	time_over = true
	_minigame_won()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		%Hand.slam(event.position.x)
