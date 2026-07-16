
extends TextureRect

var start_pos := Vector2(0,0)
var dragging := false
var off := Vector2(0,0)
var falling := false
var fall_speed : float = 600

func _ready() -> void:
	print(start_pos)
	pass
	#%Button.size = size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragging:
		position = get_global_mouse_position() - off - start_pos
		
	if falling:
		position.y += fall_speed*delta

func _on_button_button_down() -> void:
	if falling:
		return
	dragging = true
	off = get_global_mouse_position() - global_position

func _on_button_button_up() -> void:
	dragging = false
	get_parent().get_parent().get_node("Hand").drop_item(self)
