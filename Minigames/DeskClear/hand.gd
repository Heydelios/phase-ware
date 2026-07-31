extends Sprite2D

var trash_scene := preload("res://Minigames/DeskClear/trash.tscn")
var mouse_position : Vector2 = Vector2.ZERO
var difference : Vector2

var desk_start := Vector2(248,303)
var desk_end := Vector2(1024, 588)

var item_count : int = 4

func _ready() -> void:
	Events.time_over.connect(on_loss)

	desk_start = %SpawnZone.position
	desk_end = %SpawnZone.position + %SpawnZone.size
	for i in range(item_count):
		var scene := trash_scene.instantiate()
		var trash_number : int = randi_range(1,4)
		scene.texture = load("res://Minigames/DeskClear/trash" + str(trash_number) + ".png")
		scene.position = Vector2(randf_range(0, %SpawnZone.size.x),randf_range(0, %SpawnZone.size.y))
		scene.start_pos = %SpawnZone.position
		scene.z_index = 1
		%SpawnZone.add_child(scene)
	position = get_global_mouse_position()
	mouse_position = get_global_mouse_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	difference = mouse_position - get_global_mouse_position()
	global_position -= difference
	mouse_position = get_global_mouse_position()


	if Minigame.get_game(self).game_ended:
		return

func drop_item(item : TextureRect) -> void:
	print("dropped item ", item.global_position)
	if item.global_position.x < %SpawnZone.position.x:
		item.falling = true
		item_count -= 1
	if item.global_position.x > %SpawnZone.position.x + %SpawnZone.size.x:
		item.falling = true
		item_count -= 1
	if item.global_position.y + item.size.y < %SpawnZone.position.y:
		item.falling = true
		item_count -= 1
		item.z_index = -1
	if item.global_position.y > %SpawnZone.position.y + %SpawnZone.size.y:
		item.falling = true
		item_count -= 1

	if item_count == 0:
		Minigame.win_game(self)

func on_loss() -> void:
	if Minigame.get_game(self).game_ended:
		return
