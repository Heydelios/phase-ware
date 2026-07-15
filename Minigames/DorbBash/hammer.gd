extends AnimatedSprite2D

var mouse_position : Vector2 = Vector2.ZERO
var difference : Vector2
var cooldown : float = .7
var timer : float = 0
var in_cooldown : bool = false

var offset_vector := Vector2(65, -145)

func _ready() -> void:
	position = get_global_mouse_position() + offset_vector
	mouse_position = get_global_mouse_position()
	#position.x += 65
	#position.y -= 145

	#position.x = clamp(position.x, 0, 1280)
	#position.y = clamp(position.y, 0, 720)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		
	difference = mouse_position - get_global_mouse_position()
	global_position -= difference
	mouse_position = get_global_mouse_position()
	%Dot.position = %Hitbox.global_position #+ Vector2(150,0)
	if in_cooldown:
		timer += delta
		if timer > cooldown:
			timer = 0
			in_cooldown = false
			
	if Minigame.get_game(self).game_ended:
		return
			
	if Input.is_action_pressed("click") and not in_cooldown:
			in_cooldown = true
			print("click")
			%Hammer.play("bash")
			var hammer_pos := get_global_mouse_position() + offset_vector
			hammer_pos.x += 125
			hammer_pos.y += 25
			var testx = abs(%Hitbox.global_position.x-hammer_pos.x)
			var testy = abs(%Hitbox.global_position.y-hammer_pos.y)
			
			print(testy)
			if (testx < 150 && testy < 150) :
				
				print("hit")
				%Dorb.self_modulate = Color(1,1,1,0)
				%BrokenDorb.visible = true
				Minigame.win_game(self)
			print(%Hitbox.global_position)
			print(get_global_mouse_position())
