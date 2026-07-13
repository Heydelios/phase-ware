class_name Main
extends Node2D

enum main_state {INTRO, MINIGAME_START, IN_GAME, MINIGAME_END, SPEED_UP, BOSS_STAGE, GAME_OVER}
enum control_type {WASD, MASH, MOUSE_POINT, POINT_AND_CLICK}
var state := main_state.INTRO
var intro_scene := preload("res://IntroCutscene/intro.tscn")

var minigame_prompt := preload("res://Minigames/popup_text.tscn")
var main_screen_display := preload("res://UI/Television/minigame_start.tscn")
var should_transition := true

var timer : float = 0
var speed : float = 1
var lives : int = 4
var stage_number : int = 1
var wins : int = 0
var nb_of_wins_to_speedup : int = 3
var nb_of_wins_to_boss : int = 11
var should_speedup : bool = false
var should_start_boss : bool = false
var should_allow_repeats = true

@onready var anim_player := %AnimationPlayer

var minigame_list: Array[PackedScene]
var next_minigame:Minigame

func build_minigame_list():
	var game_dir = "res://Minigames/"
	for d in ResourceLoader.list_directory(game_dir):
		if d.ends_with("/"):
			for f in ResourceLoader.list_directory(game_dir + d):
				if f.ends_with(".tscn") and f.get_basename() == d.get_base_dir():
					minigame_list.append(load(game_dir + d + f))
					print(f)
						# this code is not very wheelchair accessible

func _ready() -> void:
	print("building minigame list:")
	build_minigame_list()

	Events.intro_end.connect(_on_intro_end)
	Events.minigame_won.connect(_on_minigame_won)
	Events.minigame_lost.connect(_on_minigame_lost)
	#Play intro cutscene
	var intro = intro_scene.instantiate()
	add_child(intro)

func _process(delta: float) -> void:
	match state:
		main_state.MINIGAME_START:
			minigame_start(delta)

		main_state.MINIGAME_END:
			minigame_end(delta)

		main_state.SPEED_UP:
			speed_up(delta)

		main_state.BOSS_STAGE:
			boss_stage(delta)

func minigame_start(delta: float) -> void:
	var start_anim_duration : float = 3

	if timer == 0:
		var main_screen : StartScreen = main_screen_display.instantiate()
		main_screen.control_type = next_minigame.control_type
		main_screen.duration = start_anim_duration
		main_screen.minigame_count = stage_number
		%Background.add_child(main_screen)
		should_transition = true
	
	timer += delta

	if timer >= start_anim_duration-.2 && should_transition:
		%HealthBar.anim_player.play("fade_out")
		anim_player.play("zoom_in")
		var popup = minigame_prompt.instantiate()
		popup.prompt = next_minigame.game_name
		%TextAnchor.add_child(popup)
		should_transition = false

	if timer >= start_anim_duration:
		timer = 0
		state = main_state.IN_GAME
		%GameAnchor.add_child(next_minigame)

func minigame_end(delta: float) -> void:
	var end_anim_duration : float = .5
	timer += delta
	if timer >= end_anim_duration:
		timer = 0
		state = main_state.MINIGAME_START

func boss_stage(delta: float) -> void:
	var boss_anim_duration : float = 2
	timer += delta
	if timer >= boss_anim_duration:
		timer = 0
		state = main_state.MINIGAME_START

func speed_up(delta: float) -> void:
	var speed_up_duration : float = 2
	timer += delta
	if timer >= speed_up_duration:
		speed += 0.5
		Engine.time_scale = speed
		timer = 0
		state = main_state.MINIGAME_START

func _on_intro_end() -> void:
	state = main_state.MINIGAME_START
	next_minigame = minigame_list.pick_random().instantiate()
	print("intro end")

func _on_minigame_won() -> void:
	wins += 1
	if wins % nb_of_wins_to_speedup == 0:
		should_speedup = true
		print("speed up")
		
	if wins % nb_of_wins_to_boss == 0:
		should_start_boss = true
		print("boss")
	#Play minigame won animation
	var win_anim_duration : float = .5
	print("minigame won")
	await get_tree().create_timer(win_anim_duration).timeout
	_on_minigame_end()
	
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
	%HealthBar.anim_player.play("fade_in")
	anim_player.play("zoom_out")
	stage_number += 1
	next_minigame = minigame_list.pick_random().instantiate()
	if should_speedup:
		state = main_state.SPEED_UP
		should_speedup = false
		#Play Faster animation
		return
	if should_start_boss:
		state = main_state.BOSS_STAGE
		should_start_boss = false
		speed = 1
		Engine.time_scale = speed
		#Play Boss animation
		return
	state = main_state.MINIGAME_END

func _on_game_over() -> void:
	state = main_state.GAME_OVER
		#Play minigame lost animation
	var gameover_anim_duration : float = .5
	await get_tree().create_timer(gameover_anim_duration).timeout
