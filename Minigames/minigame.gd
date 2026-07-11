class_name Minigame
extends Node2D

@export var game_name : String
@export var control_type : Main.control_type
@onready var speed : float = 1

var time_allowed : float = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.time_over.connect(_minigame_loss)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _unhandled_input(event):
	pass



func _minigame_loss() -> void:
	Events.minigame_lost.emit()
	queue_free()

func _minigame_won() -> void:
	Events.minigame_won.emit()
	queue_free()
