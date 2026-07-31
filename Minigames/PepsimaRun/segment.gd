extends Node3D

const FULL_BLOCK_1 = preload("uid://sj22l65rsa3")
const FULL_BLOCK_2 = preload("uid://df1plsbdquucw")
var blocks = [FULL_BLOCK_1,FULL_BLOCK_2]
@onready var marker_3d: Marker3D = $Marker3D
@onready var marker_3d_2: Marker3D = $Marker3D2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var slots = [marker_3d,marker_3d_2]
	for slot in slots:
		var block:Node3D= blocks[randi_range(0,1)].instantiate()
		slot.add_child(block)
		block.rotation_degrees.y = 90*(randi_range(0,3))
	
