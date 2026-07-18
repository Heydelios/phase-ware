extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("AnimationPlayer").play("car_drive")
	get_node("AnimationPlayer2").play("piantafk_drive")
	get_node("AnimationPlayer3").play("piantiana_drive")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
