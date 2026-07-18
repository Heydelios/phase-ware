extends TextureRect

var mouse_position : Vector2 = Vector2.ZERO
var difference : Vector2
var is_killed := false

var jfk_death_pos : Vector3
var diana_death_pos : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%car.get_node("AnimationPlayer").play("car_drive")
	%piantafk.get_node("AnimationPlayer").play("piantafk_drive")
	%piantana.get_node("AnimationPlayer").play("piantiana_drive")
	position = get_global_mouse_position() - Vector2(2560.0, 1440.0)
	mouse_position = get_global_mouse_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if is_killed:
		%piantafk.get_node("MonteM__m_MonteM").position = jfk_death_pos
		
	if Minigame.get_game(self).game_ended:
		return
		
	difference = mouse_position - get_global_mouse_position()
	global_position -= difference
	mouse_position = get_global_mouse_position()
	
	print(%piantafk.get_node("MonteM__m_MonteM").position , " ", is_killed)
	
		#%piantana.get_node("MonteW__m_MonteW").position += diana_death_pos

func _on_pianta_button_pressed() -> void:
	is_killed = true
	print(is_killed)
	Minigame.win_game(self)
	self_modulate = Color(1,1,1,0)
	
	jfk_death_pos = %piantafk.get_node("MonteM__m_MonteM").position
	diana_death_pos = %piantana.get_node("MonteW__m_MonteW").position
	
	%car.get_node("AnimationPlayer").pause()
	%piantafk.get_node("AnimationPlayer").play("death")
	%piantana.get_node("AnimationPlayer").play("run_away")
	var anim: Animation = %piantana.get_node("AnimationPlayer").get_animation("run_away")
	
	var key_amount : int = anim.track_get_key_count(0)
	for i in range(key_amount):
		var pos_val : Vector3 = anim.track_get_key_value(0, i)
		print(pos_val)
		if i < 16:
			anim.track_set_key_value(0, i, diana_death_pos)
		else:
			anim.track_set_key_value(0, i, diana_death_pos - Vector3((i-16), 0, 0))
	
	pass # Replace with function body.
