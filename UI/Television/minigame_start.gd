class_name StartScreen
extends Control

@onready var control_type : Main.control_type
@onready var minigame_count : int
@onready var duration : float
var snow_duration = 0.4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ControlDisplay.update_display(control_type)
	
	%Value.text = str(minigame_count)
	if minigame_count < 10:
		%Value.text = "0" + str(minigame_count)
	
	duration = (duration-snow_duration)/2
	duration -= snow_duration
	get_tree().create_timer(duration).timeout.connect(display_snow)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display_snow() -> void:
	%ControlDisplay.visible = false
	%Snow.visible = true
	get_tree().create_timer(snow_duration).timeout.connect(display_counter)
	
func display_counter() -> void:
	%Snow.visible = false
	%MinigameCounter.visible = true
	get_tree().create_timer(duration).timeout.connect(hide_counter)
	
func hide_counter() -> void:
	print("go here?")
	%MinigameCounter.visible = false
	%Snow.visible = true
	get_tree().create_timer(snow_duration).timeout.connect(queue_free)
