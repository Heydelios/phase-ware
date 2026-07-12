extends AnimatedSprite2D

var mash_needed : int = 20
var mash_counter : int = 0

func _unhandled_input(event):
	if Minigame.get_game(self).time_over:
		return
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("spacebar"):
			mash_counter += 1
			print("mash + 1")
			play("eat")
			if mash_counter == mash_needed:
				%AnimationPlayer.play("bowl_eaten")
				Minigame.win_game(self)
