extends Button

var name_array = ["Bunty", "Kotazuma", "Ashers", "Imp", "Jody", "Heydelios", "AirlineFood", "Grispinne", "Bababababa", "Coedo",
 "Awa+Anon", "Paquet", "Sexd_Ur_Mum", "QWERTY", "Boneharvest", "Freakndumb",
"Magosis", "J.K.Howard", "RedWardStudio", "Spackle", "Yohanezz",
 "DMonstrous", "Dr.Wol", "PotionDweller", "StellatedCUBE", "BigApplePie", "AnimalFriendPartII",
 "BingoPanic", "BuncyTheFrog", "BurningCactus", "BurntSalsa", "CallMeJam", "Cameron", "DBAC",
 "DigisPizza", "Jordan", "LucaChuba", "NiiCola", "Onii", "Peppy", "Scamela", "ScopelessOne", "ShadooLiger",
"Skygears", "Turminal", "Xynchro"]

var is_wrong := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%name.text = name_array.pick_random()

	if randi_range(0,1) == 0:
		%name.modulate = Color("a4a4a4")
	else:
		%name.modulate = Color("48954d")

	%text.text = ""
	if !is_wrong:
		%text.text = "a"
	var string := "wa"
	var max_wa : int = 11
	max_wa = (20 - %name.text.length())/2
	for i in range(randi_range(1,max_wa)):
		%text.text += string


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if global_position.y < 150:
		self_modulate = Color(0,0,0,0)
		if is_wrong:
			get_parent().wrong_ban()


func _on_pressed() -> void:
	if Minigame.get_game(self).game_ended:
		return
	%AnimationPlayer.play("banned")
	if is_wrong:
		get_parent().correct_ban()
	else:
		get_parent().wrong_ban()
