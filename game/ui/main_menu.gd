extends Control

func _ready():
	get_node("blue_team").set_text("Blue Team : " + str(start.blue_score) + " WIN")
	get_node("red_team").set_text("Red Team : " + str(start.red_score) + " WIN")
	initialize_player_buttons()
	set_process_input(true)

func _on_play_pressed():
	for i in [1, 2]:
		start.set(
			"player%d_knight" % i,
			start.preset_knights[get_node("pick_knight/player%d" % i).get_text()]
		)
	get_tree().change_scene("res://main.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()

func initialize_player_buttons():
	for i in [1, 2]:
		var pick_button = get_node("pick_knight/player%d" % i)
		for key in start.preset_knights:
			pick_button.add_item(key)