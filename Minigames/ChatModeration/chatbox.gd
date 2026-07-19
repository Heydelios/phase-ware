extends VBoxContainer

var timer : float = 0
var total_time : float = 0
var messsage_scene := preload("res://Minigames/ChatModeration/chat_message.tscn")

var total_to_ban : int = 2
var nb_to_ban : int = total_to_ban
var correct_bans : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Minigame.get_game(self).game_ended:
		return
	timer += delta
	total_time += delta
	var rand := randf_range(.45, .9)
	if timer > rand:
		timer -= rand
		spawn_message()
		
func spawn_message() -> void:
	var message = messsage_scene.instantiate()
	if total_time > 5:
		self.add_child(message)
		return
	
	if total_time > 1.5 && nb_to_ban == 2:
		message.is_wrong = true
		nb_to_ban -= 1
		self.add_child(message)
		return
		
	if total_time > 3 && nb_to_ban == 1:
		message.is_wrong = true
		nb_to_ban -= 1
		self.add_child(message)
		return
		
	if randi_range(0,100) > 80 && nb_to_ban > 0:
		message.is_wrong = true
		nb_to_ban -= 1

	self.add_child(message)

func correct_ban() -> void : 
	correct_bans += 1
	if correct_bans == total_to_ban:
		Minigame.win_game(self)
		
func wrong_ban() -> void : 
	Minigame.lose_game(self)
