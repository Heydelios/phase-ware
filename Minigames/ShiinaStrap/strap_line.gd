extends Line2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.time_over.connect(on_loss)

func _process(delta):
	if Minigame.get_game(self).game_ended:
			return
	if points.size() > 0:
		set_point_position(points.size()-1,get_global_mouse_position()) 

func _on_button_2_pressed() -> void:
	%Button2.disabled = true
	%Button3.visible = true
	add_point(%Button2.position)


func _on_button_3_pressed() -> void:
	%Button3.disabled = true
	%Button4.visible = true
	add_point(%Button3.position)


func _on_button_4_pressed() -> void:
	%Button4.disabled = true
	%Button5.visible = true
	add_point(%Button4.position)


func _on_button_5_pressed() -> void:
	%Button5.disabled = true
	visible = false
	%Button1.visible = false
	%Button2.visible = false
	%Button3.visible = false
	%Button4.visible = false
	%Button5.visible = false
	%AnimSprite.play("success")
	Minigame.win_game(self)
	
func on_loss() -> void:
	visible = false
	%Button1.visible = false
	%Button2.visible = false
	%Button3.visible = false
	%Button4.visible = false
	%Button5.visible = false
	%AnimSprite.play("failure")
	pass
