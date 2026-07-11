class_name ControlDisplay
extends TextureRect

var control_type : Main.control_type
@onready var duration : float = .3

var texture_array : Array[Texture2D] = [
	preload("res://UI/ControlDisplay/wasd_icon.png"),
	preload("res://UI/ControlDisplay/mash_icon.png"),
	preload("res://UI/ControlDisplay/point_icon.png"),
	preload("res://UI/ControlDisplay/pointnclick_icon.png"),
]

func update_display(type: Main.control_type) -> void:
	control_type = type
	texture = texture_array[control_type]
