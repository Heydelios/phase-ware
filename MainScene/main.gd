class_name Main
extends Node2D

enum main_state {INTRO, MINIGAME_START, IN_GAME, MINIGAME_END, GAME_OVER}
enum control_type {WASD, MASH, MOUSE_POINT, POINT_AND_CLICK}
var state := main_state.INTRO
var intro_scene := preload("res://IntroCutscene/intro.tscn")

var minigame_list : Array[String] = preload("res://MinigameList.tres").path_list
var next_minigame : Minigame
var minigame_prompt := preload("res://Minigames/popup_text.tscn")
var main_screen_display := preload("res://UI/Television/minigame_start.tscn")

var timer : float = 0
var lives : int = 4
var speed : float = 1
var stage_number : int = 1

@onready var anim_player := %AnimationPlayer

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
	var start_anim_duration : float = 3
	
	if timer == 0:
		var main_screen : StartScreen = main_screen_display.instantiate()
		main_screen.control_type = next_minigame.control_type
		main_screen.duration = start_anim_duration
		main_screen.minigame_count = stage_number
		%Background.add_child(main_screen)
	
	timer += delta
	
	if timer >= start_anim_duration-.2:
		%HealthBar.anim_player.play("fade_out")
		anim_player.play("zoom_in")
		
	if timer >= start_anim_duration:
		timer = 0
		state = main_state.IN_GAME
		var popup = minigame_prompt.instantiate()
		popup.prompt = next_minigame.game_name
		%Anchor.add_child(next_minigame)
		%Anchor.add_child(popup)
		
	print("gamestart " + str(timer))
	
func minigame_end(delta: float) -> void:
	if timer == 0:
		anim_player.play("zoom_out")
	var end_anim_duration : float = .5
	timer += delta
	if timer >= end_anim_duration:
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
	var win_anim_duration : float = .5
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
	var loss_anim_duration : float = .5
	%HealthBar.lose_hp(lives)
	print("minigame lost")
	await get_tree().create_timer(loss_anim_duration).timeout
	_on_minigame_end()
	
func _on_minigame_end() -> void:
	state = main_state.MINIGAME_END
	%HealthBar.anim_player.play("fade_in")
	stage_number += 1
	
func _on_game_over() -> void:
	state = main_state.GAME_OVER
		#Play minigame lost animation
	var gameover_anim_duration : float = .5
	await get_tree().create_timer(gameover_anim_duration).timeout
	
