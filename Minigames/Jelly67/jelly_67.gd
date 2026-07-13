extends AnimatedSprite2D

var window_height : float = 720
var frames : int = 6
var mouse_y_position : float
var checkpoints : Array[float]
var play_area : int = 500
var border_width : int

var going_up := false
var swap_dir_counter : int = 0
var win_target : int = 9

func get_cursor_index() -> int :
	var cmp : int = 0
	for i in range(frames):
		if get_global_mouse_position().y > checkpoints[i]:
			cmp += 1
	return cmp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	border_width = (window_height - play_area) / 2
	for i in range(frames):
		checkpoints.append(border_width + i*play_area/frames)
	var start_frame : int = get_cursor_index()
	%Jelly67.pause()
	%Jelly67.frame = start_frame
	if start_frame > frames/2:
		going_up = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	six_seven()
	if swap_dir_counter == win_target:
		Sfx.play_sfx("six_seven")
		Minigame.win_game(self)
		swap_dir_counter += 1

func six_seven() -> void:
	var cursor_id := get_cursor_index()
	if cursor_id > %Jelly67.frame && !going_up:
		%Jelly67.frame += 1
		if %Jelly67.frame == frames-1:
			going_up = true
			swap_dir_counter += 1
		return
		
	if cursor_id < %Jelly67.frame && going_up:
		%Jelly67.frame -= 1
		if %Jelly67.frame == 0:
			going_up = false
			swap_dir_counter += 1
