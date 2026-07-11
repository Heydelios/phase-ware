extends TextureButton

const SPEED = 300.0
var velocity: Vector2

func _ready() -> void:
	velocity = Vector2(
		[1, 0.5, -1, -0.5].pick_random(),
		[1, 0.5 ,-1, -0.5].pick_random()
	).normalized() * SPEED

func _process(delta: float) -> void:
	position += velocity * delta
	
	var r = get_rect()
	var world_size = Vector2(512,480) #Minigame.get_game(self).size
	
	
	var max_x = world_size.x - r.size.x
	var max_y = world_size.y - r.size.y
	
	if position.x < 0:
		position.x = 0
		velocity.x *= -1
	elif position.x > max_x:
		position.x = max_x
		velocity.x *= -1
	if position.y < 0:
		position.y = 0
		velocity.y *= -1
	elif position.y > max_y:
		position.y = max_y
		velocity.y *= -1
