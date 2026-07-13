class_name Minigame
extends Node

@export var game_name : String
@export var control_type : Main.control_type
@export var should_win_on_timeover : bool = false

var time_over : bool = false
var win_cutscene_duration = .5
var loss_cutscene_duration = .5

func _ready() -> void:
	Events.time_over.connect(_time_over)

func set_position(pos:Vector2):
	# OOP is so cool
	var base = self as Node
	if base is Control:
		base.position = pos
	elif base is Node2D:
		base.position = pos

func screenshake(amplitude : float = 10.0, duration : float = 0.3) -> void:
	var elapsed := 0.0
	while elapsed < duration:
		var decay := 1.0 - elapsed / duration
		var offset := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * amplitude * decay
		set_position(offset)
		$Background.position = -offset
		elapsed += get_process_delta_time()
		await get_tree().process_frame
	set_position(Vector2.ZERO)
	$Background.position = Vector2.ZERO

func _time_over() -> void:
	time_over = true
	if should_win_on_timeover:
		_minigame_won()
	else:
		_minigame_loss()

func _minigame_loss() -> void:
	#need delay to play loss anim
	await get_tree().create_timer(loss_cutscene_duration).timeout
	Events.minigame_lost.emit()
	queue_free()

func _minigame_won() -> void:
	#need delay to play win anim
	await get_tree().create_timer(win_cutscene_duration).timeout
	Events.minigame_won.emit()
	queue_free()

static func get_game(from:Node) -> Minigame:
	var curr = from
	while curr:
		if curr is Minigame:
			return curr
		curr = curr.get_parent()
	return null

static func win_game(from:Node):
	get_game(from)._minigame_won()

static func lose_game(from:Node):
	get_game(from)._minigame_loss()
