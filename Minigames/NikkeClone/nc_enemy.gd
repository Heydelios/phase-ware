extends Node2D

signal enemy_died

var hp:int = 1
var direction:int = 1
var initial_target:Vector2=Vector2.ZERO
var target_reached:bool = false
var targeted:bool = false
const SPEED = 100

@onready var timer: Timer = $Timer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const MEDS = preload("uid://c7hgsppojuuyv")

func _ready() -> void:
	initial_target.x = randi_range(200,1080)
	initial_target.y=	randi_range(160,360)
	audio_stream_player.stream = MEDS
	audio_stream_player.pitch_scale= randf_range(0.8,1.3)
	audio_stream_player.play()


func _process(delta: float) -> void:
	if not target_reached:
		global_position.x = move_toward(global_position.x,initial_target.x,1)
		global_position.y = move_toward(global_position.y,initial_target.y,1)
		if global_position == initial_target:
			target_reached = true
			timer.start()
	else:
		global_position.x+=direction*SPEED*delta




func hit():
	hp-=1
	if hp<=0:
		die()

func die():
	enemy_died.emit()
	queue_free()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and targeted:
		hit()



func _on_timer_timeout() -> void:
	direction =randi_range(-1,1)
	timer.wait_time=randi_range(1,5)
	timer.start()


func _on_area_2d_mouse_entered() -> void:
	targeted = true


func _on_area_2d_mouse_exited() -> void:
	targeted = false
