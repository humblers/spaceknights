extends Control
	
func _ready():
	get_node("Background/blue_team").set_text("Blue Team : " + str(variants.blue_score) + " WIN")
	get_node("Background/red_team").set_text("Red Team : " + str(variants.red_score) + " WIN")
	get_node("Deck").hide()
	get_node("Shop").hide()
	if variants.preset_knights.size() <= 0:
		get_node("Deck").show_deck_menu()
	set_process_input(true)

func _on_play_pressed():
	variants.set("player1_knight",variants.preset_knights[get_node("Deck").cur_deck_key])
	kcp.connect("match_opponent", self, "_matched")
	kcp.write(kcp.FIND_OPPONENT, variants.player1_knight)

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()

func _on_HButtonArray_button_selected( button_idx ):
	if button_idx == 0:
		get_node("Deck").show_deck_menu()
		get_node("Shop").hide()
	elif button_idx == 1:
		get_node("Deck").hide()
		get_node("Shop").hide()
	elif button_idx == 2:
		get_node("Deck").hide()
		get_node("Shop").show()

func _matched(dict):
	var opponent_uid
	for uid in dict["message"]:
		if int(uid) != kcp.uid:
			opponent_uid = uid
	variants.set("player2_knight", dict["message"][opponent_uid])
	print(variants.player1_knight)
	print(variants.player2_knight)
	get_tree().change_scene("res://main.tscn")