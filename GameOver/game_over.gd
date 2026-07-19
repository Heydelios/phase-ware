extends Control

var games_completed : int = 0
var max_speed : float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Desc.text = %Desc.text.replace('F', str(games_completed))
	%Desc.text = %Desc.text.replace('Z', str(max_speed))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("spacebar"):
			get_tree().change_scene_to_file("res://MainScene/main.tscn")
