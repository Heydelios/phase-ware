class_name Minigame
extends Node

@export var game_name : String
@export var control_type : Main.control_type
@onready var speed : float = 1

var time_allowed : float = 100

func _ready() -> void:
	Events.time_over.connect(_minigame_loss)

func _minigame_loss() -> void:
	Events.minigame_lost.emit()
	queue_free()

func _minigame_won() -> void:
	Events.minigame_won.emit()
	queue_free()

static func get_game(from:Node):
	var curr = from
	while curr:
		if curr is Minigame:
			return curr
		curr = curr.get_parent()

static func win_game(from:Node):
	get_game(from)._minigame_won()

static func lose_game(from:Node):
	get_game(from)._minigmae_loss()
