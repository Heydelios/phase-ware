extends Node2D

enum main_state {INTRO, MINIGAME_START, IN_GAME, MINIGAME_END, GAME_OVER}
enum control_type {WASD, MASH, MOUSE_POINT, MOUSE_CLICK}
var state := main_state.INTRO
var intro_scene := preload("res://Scenes/intro.tscn")
var minigame_list : Array[String] = preload("res://MinigameList.tres").path_list
var next_minigame : Minigame

var timer : float = 0
var lives : int = 4
var speed : float = 1
var stage_number : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.intro_end.connect(_on_intro_end)
	Events.minigame_won.connect(_on_minigame_won)
	Events.minigame_lost.connect(_on_minigame_lost)
	#Play intro cutscene
	var intro = intro_scene.instantiate()
	add_child(intro)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		main_state.MINIGAME_START:
			minigame_start(delta)
			
		main_state.MINIGAME_END:
			minigame_end(delta)
	pass


func minigame_start(delta: float) -> void:
	timer += delta
	if timer >= 3:
		timer = 0
		state = main_state.IN_GAME
		add_child(next_minigame)
	print("gamestart " + str(timer))
	
func minigame_end(delta: float) -> void:
	timer += delta
	if timer >= 3:
		next_minigame = load(minigame_list.pick_random()).instantiate()
		timer = 0
		state = main_state.MINIGAME_START
	print("gameend " + str(timer))
	
	
func _on_intro_end() -> void:
	state = main_state.MINIGAME_START
	var scene := load("res://Minigames/JordanMinigame/example_game.tscn")
	next_minigame = scene.instantiate()
	print("intro end")

func _on_minigame_won() -> void:
	#Play minigame won animation
	var win_anim_duration : float = 1
	print("minigame won")
	await get_tree().create_timer(win_anim_duration).timeout
	
	_on_minigame_end()
	pass
	
func _on_minigame_lost() -> void:
	lives -= 1
	if lives == 0:
		_on_game_over()
		return
	#Play minigame lost animation
	var loss_anim_duration : float = 2
	print("minigame lost")
	await get_tree().create_timer(loss_anim_duration).timeout
	_on_minigame_end()
	
func _on_minigame_end() -> void:
	state = main_state.MINIGAME_END
	stage_number += 1
	
func _on_game_over() -> void:
	state = main_state.GAME_OVER
		#Play minigame lost animation
	var gameover_anim_duration : float = 5
	await get_tree().create_timer(gameover_anim_duration).timeout
	
