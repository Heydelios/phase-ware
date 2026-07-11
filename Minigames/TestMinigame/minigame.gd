class_name Minigame
extends Node2D

@export var game_name : String
@export var control_type : int
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
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("spacebar"):
			Events.minigame_won.emit()
			queue_free()
		if event.pressed and event.is_action_pressed("up"):
			_minigame_loss()
		
func _minigame_loss() -> void:
	Events.minigame_lost.emit()
	queue_free()
