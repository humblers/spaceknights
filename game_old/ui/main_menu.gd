extends Control

func _ready():
	get_node("Background/blue_team").set_text("Blue Team : " + str(variants.blue_score) + " WIN")
	get_node("Background/red_team").set_text("Red Team : " + str(variants.red_score) + " WIN")
	
	get_node("Background/login_panel/id").set_text(variants.last_uid)

	get_node("HButtonArray").hide()
	get_node("Background/play").hide()
	get_node("Deck").hide()
	get_node("Shop").hide()

	set_process_input(true)

func _on_login_pressed():
	http_lobby.connect("login_response", self, "_login_response")
	var id = get_node("Background/login_panel/id").get_text()
	var params = {}
	if id and not id.empty():
		params["id"] = id
	http_lobby.request(HTTPClient.METHOD_POST, "/login/dev", params, "login_response", false)

func _on_play_pressed():
	variants.set("player1_knight",variants.preset_knights[get_node("Deck").cur_deck_key])
	get_tree().change_scene("res://main.tscn")

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

func _login_response(success, ret):
	var loggedin_uid = ret["id"]
	get_node("Background/login_panel/login").hide()
	get_node("Background/login_panel/id").set_text(loggedin_uid)
	variants.last_uid = loggedin_uid
	variants.save_player_data()

	get_node("HButtonArray").show()
	get_node("Background/play").show()
	if variants.preset_knights.size() <= 0:
		_on_HButtonArray_button_selected(0)
		get_node("HButtonArray").set_selected(0)

func _matched(dict):
	var opponent_uid
	for uid in dict["message"]:
		if int(uid) != kcp.uid:
			opponent_uid = uid
	variants.set("player2_knight", dict["message"][opponent_uid])
	print(variants.player1_knight)
	print(variants.player2_knight)
	get_tree().change_scene("res://main.tscn")