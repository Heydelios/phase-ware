extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%car.get_node("AnimationPlayer").play("car_drive")
	%piantafk.get_node("AnimationPlayer").play("piantafk_drive")
	%piantana.get_node("AnimationPlayer").play("piantiana_drive")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	print("terst")
