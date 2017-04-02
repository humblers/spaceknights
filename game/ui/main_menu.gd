extends Control

func _ready():
	get_node("blue_team").set_text("Blue Team : " + str(start.blue_score) + " WIN")
	get_node("red_team").set_text("Red Team : " + str(start.red_score) + " WIN")
	"""
	for player in ["player1", "player2"]:
		initialize_knight_type_button(player)
	update_skill_queue()
	"""
	set_process_input(true)

func _on_play_pressed():
	var p1_button = get_node("picked_type_player1")
	start.player1_type = p1_button.get_selected_ID()
	var p2_button = get_node("picked_type_player2")
	start.player2_type = p2_button.get_selected_ID()
	start.save_player_data(p1_button.get_selected(), p2_button.get_selected())
	get_tree().change_scene("res://main.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()

