extends Minigame

const NC_ENEMY = preload("uid://csgfhmswtos4q")
const LINE_OF_SIGHT_Y:int = 375
const GUN = preload("uid://dii8lie43tthm")

var enemy_amount:int= 7
var enemies_to_spawn: int = 7
var enemies_killed:int = 0

var aiming:bool = false
var shooting:bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spawners:Array[Marker2D]=[$Spawner,$Spawner2]
@onready var reticle: Sprite2D = $Reticle
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	super()
	audio_stream_player.stream = GUN
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:		

	if not aiming:
		animation_player.play("idle")
	else:
		if not shooting:
			animation_player.play("aim")
	
	if time_over and enemies_killed<enemies_to_spawn:
		Minigame.lose_game(self)
	
func _input(event: InputEvent) -> void:
	if game_ended:
		return
		
	if event is InputEventMouseMotion:
		reticle.position =event.position
		if event.position.y < LINE_OF_SIGHT_Y:
			aiming = true
		else:
			aiming = false
			
	if event is InputEventMouseButton and aiming:
		shooting = true
		audio_stream_player.play()
		animation_player.play("shoot")
		
func _on_enemy_timer_timeout() -> void:
	if enemies_to_spawn>0:
		var new_enemy = NC_ENEMY.instantiate()
		add_child(new_enemy)
		new_enemy.global_position = spawners[randi_range(0,1)].global_position
		new_enemy.enemy_died.connect(_on_enemy_died)
		enemies_to_spawn-=1
		
func _on_enemy_died():
	enemies_killed+=1
	if enemies_killed>=enemy_amount:
		Minigame.win_game(self)
		animation_player.play("idle")
		FastEnd()
	
func FastEnd():
	if !time_over:
		Events.time_over.emit()
		
func _on_shoot_end():
	shooting = false
