class_name Minigame
extends Node

@export var game_name : String
@export var control_type : Main.control_type

var time_over : bool = false
var win_cutscene_duration = .5
var loss_cutscene_duration = .5

func _ready() -> void:
	Events.time_over.connect(_minigame_loss)

func _minigame_loss() -> void:
	time_over = true
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
