extends CharacterBody2D

const speed:float = 700.0
const accel:float = 1800

var alive = true

enum Frames {IDLE, RUN_0, RUN_1, DEAD}

func run_cycle():
	Sfx.play_sfx("clap")
	$Sprite2D.frame += 1
	if $Sprite2D.frame >= Frames.DEAD:
		$Sprite2D.frame = Frames.RUN_0

var run_cumer = Cumer.new(1.0/80, run_cycle)
func _process(delta):
	if not alive:
		return
	$Sprite2D.flip_h = velocity.x > 0
	var spd = abs(velocity.x)
	if spd < 10:
		$Sprite2D.frame = Frames.IDLE
	else:
		run_cumer.add(spd * delta)

func pick_direction():
	if not alive:
		return
	direction = [-1, 1].pick_random()
	await get_tree().create_timer([1,2,3,4].pick_random()).timeout
	pick_direction()

var direction:float
func _physics_process(delta: float) -> void:
	direction += Input.get_axis("ui_left", "ui_right")
	velocity.x = move_toward(velocity.x, direction * speed, accel*delta)
	move_and_slide()
	if position.x < 0 or position.x > 1280:
		Minigame.lose_game(self)

func _ready():
	await get_tree().create_timer([1,2,3,4].pick_random()).timeout
	pick_direction()

func squish():
	Sfx.play_sfx("gong")
	Minigame.lose_game(self)
	alive = false
	direction = 0
	$Sprite2D.frame = Frames.DEAD
