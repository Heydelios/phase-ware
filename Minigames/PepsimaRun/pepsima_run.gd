extends Minigame

@onready var animation_player: AnimationPlayer = $SubViewportContainer/SubViewport/Node3D/maemi_pepsima/AnimationPlayer
@onready var maemi_pepsima: Node3D = $SubViewportContainer/SubViewport/Node3D/maemi_pepsima
@onready var horizon_spawner: Node3D = $SubViewportContainer/SubViewport/Node3D/HorizonSpawner
@onready var obstacle_spawn_timer: Timer = $ObstacleSpawnTimer
const SEGMENT = preload("uid://g37u2xr1oaym")
const SPEED:int = 45

var lanes:Array[float]=[-3.0,0.0,3.0]
var lane_pos:int = 1
var background_array:Array=[]
var dead:bool = false

const OBSTACLE_CAR = preload("uid://d0qi6msqhrmd2")
const OBSTACLE_CONE = preload("uid://bgb05ikxrjrei")
const OBSTACLE_FENCE = preload("uid://be7no2fv7d871")
const OBSTACLE_HAG = preload("uid://c2wk6u6k8kgcn")

var obstacle_list = [
	[OBSTACLE_CAR,[-1,1]],
	[OBSTACLE_CONE,[-1,0,1]],
	[OBSTACLE_FENCE,[-1,0]],
	#[OBSTACLE_HAG,[-2,2]]
	
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	animation_player.play("run_pepsima")
	_on_build_timer_timeout()
	obstacle_spawn_timer.wait_time = randf_range(0.5,0.8)
	obstacle_spawn_timer.timeout.connect(_on_obstacle_timer_timeout)
	obstacle_spawn_timer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dead:
		return
	if game_ended:
		animation_player.play("idle_pepsima")
	for asset in background_array:
		asset.position.z-=SPEED*delta
	
	if Input.is_action_just_pressed("left")and lane_pos<2:
		animation_player.play("side_left_pepsima")
		lane_pos+=1
		maemi_pepsima.position.x=lanes[lane_pos]
		await animation_player.animation_finished
		animation_player.play("run_pepsima")
	if Input.is_action_just_pressed("right") and lane_pos>0:
		animation_player.play("side_right_pepsima")
		lane_pos-=1
		maemi_pepsima.position.x=lanes[lane_pos]
		await animation_player.animation_finished
		animation_player.play("run_pepsima")
func _on_build_timer_timeout() -> void:
	var road_piece = SEGMENT.instantiate() 
	horizon_spawner.add_child(road_piece)
	road_piece.position = horizon_spawner.position
	road_piece.rotation_degrees.y = 90
	background_array.append(road_piece)


func _on_destroy_timer_timeout() -> void:
	if background_array.size()>0:
		background_array.pop_front().queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	Minigame.lose_game(self)
	dead = true
	animation_player.play("death_pepsima")
	await animation_player.animation_finished
	FastEnd()

func _on_obstacle_timer_timeout():
	if dead or game_ended:
		return
	var new_obstacle = obstacle_list[
						randi_range(0,obstacle_list.size()-1)
						]
	print(new_obstacle)
	var nos = new_obstacle[0].instantiate()
	horizon_spawner.add_child(nos)
	nos.position = horizon_spawner.position
	nos.position.x = lanes[
						new_obstacle[1][
							randi_range(0,new_obstacle[1].size()-1)
							]
						]
	background_array.append(nos)
	obstacle_spawn_timer.wait_time=randf_range(0.3,0.6)
	obstacle_spawn_timer.start()
	
func FastEnd():
	if !time_over:
		Events.time_over.emit()


	
	
