extends Minigame

var isOverlapping:bool = false
var hitEmote = load("res://Minigames/BottleShoot/EmoteHit.png")
var missEmote = load("res://Minigames/BottleShoot/EmoteMiss.png")
var hasFired = false

func _ready() -> void:
	super()
	$AnimationPlayer.play("Cycle")
	$Table.play("Wait")
	$Panko.play("Wait")

func _physics_process(_delta: float) -> void:
	var fire = Input.is_action_just_pressed("click")

	if fire and isOverlapping:
		if !hasFired:
			Fire()
			$Table.play("Hit")
			await get_tree().create_timer(.5).timeout
			$Emote.set_texture(hitEmote)
			$AnimationPlayer.play("Win")
			Minigame.win_game(self)
			await get_tree().create_timer(1).timeout
			FastEnd()

	if fire and !isOverlapping:
		if !hasFired:
			Fire()
			await get_tree().create_timer(.5).timeout
			$Emote.set_texture(missEmote)
			$AnimationPlayer.play("Loss")
			Minigame.lose_game(self)
			await get_tree().create_timer(1).timeout
			FastEnd()

func Fire():
	hasFired = true
	$Panko.play("Shoot")
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.stop(true)

func FastEnd():
	if !time_over:
		Events.time_over.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area:
		isOverlapping = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area:
		isOverlapping = false
