extends TextureButton

var start_pos := Vector2(0,0)
var dragging := false
var off := Vector2(0,0)

var foot_pos : Vector2
var shoe_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.time_over.connect(on_loss)

	var random_rot : float = randf_range(0,90)
	#%Foot.rotation = random_rot
	#%Shoe.rotation = random_rot

	%Foot.position = Vector2(randf_range(-80, 1080), randf_range(-190, 300))
	%Shoe.position = Vector2(randf_range(-80, 1080), randf_range(-190, 300))
	while dist_condition():
		%Shoe.position = Vector2(randf_range(200, 1080), randf_range(330, 390))

func dist_condition() -> bool:
	var x : float = (%Shoe.position.x - %Foot.position.x)*(%Shoe.position.x - %Foot.position.x)
	var y : float = (%Shoe.position.y - %Foot.position.y)*(%Shoe.position.y - %Foot.position.y)
	var dist = sqrt(x + y)
	print(dist)
	if dist > 250:
		return false
	return true

func are_overlapping() -> bool:
	if abs(%Shoe.position.x - %Foot.position.x) > 80:
		#print("x", abs(%Shoe.position.x - %Foot.position.x))
		return false

	if abs(%Shoe.position.y - %Foot.position.y) > 80:
		#print("y", abs(%Shoe.position.y - %Foot.position.y))
		return false

	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Minigame.get_game(self).game_ended:
		return

	if dragging:
		dist_condition()
		print(position, "\t", get_global_mouse_position())
		position = get_global_mouse_position() - off - Vector2(120, 126)
	else:
		if are_overlapping():
			Minigame.win_game(self)


func _on_button_down() -> void:
	dragging = true
	off = get_global_mouse_position() - global_position


func _on_button_up() -> void:
	dragging = false

func on_loss() -> void:
	if Minigame.get_game(self).game_ended:
		return
