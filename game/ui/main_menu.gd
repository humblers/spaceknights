extends Control

func _ready():
	get_node("blue_team").set_text("Blue Team : " + str(start.blue_score) + " WIN")
	get_node("red_team").set_text("Red Team : " + str(start.red_score) + " WIN")
	for button_name in ["picked_type_player1", "picked_type_player2"]:
		initialize_knight_type_button(button_name)
	update_skill_queue()
	set_process_input(true)

func _on_play_pressed():
	start.player1_type = get_node("picked_type_player1").get_selected_ID()
	start.player2_type = get_node("picked_type_player2").get_selected_ID()
	get_tree().change_scene("res://main.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()

func initialize_knight_type_button(button_name):
	var pick_button = get_node(button_name)
	pick_button.clear()
	var skill_len = constants.KNIGHTS.size()
	pick_button.add_item("random", skill_len)
	for i in range(skill_len):
		pick_button.add_item(constants.KNIGHTS[i]["type"], i)

func update_skill_panel(player):
	var button_parent = get_node("picked_skill_%s/scroll/skill_queue" % player)
	for prev_button in button_parent.get_children():
		prev_button.queue_free()
	var skill_tscn = preload("res://ui/skill_button.tscn")
	for i in range(start.get("%s_skill_queue" % player).size()):
		var button = skill_tscn.instance()
		button.player = player
		button.skill_type = start.get("%s_skill_queue" % player)[i]
		button.queue_idx = i
		button_parent.add_child(button)

func update_skill_queue(players=null):
	if players == null:
		players = ["player1", "player2"]
	for player in players:
		update_skill_panel(player)
