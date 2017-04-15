extends Control
func _ready():
	get_node("blue_team").set_text("Blue Team : " + str(variants.blue_score) + " WIN")
	get_node("red_team").set_text("Red Team : " + str(variants.red_score) + " WIN")
	build_player_buttons()
	set_process_input(true)

func _on_play_pressed():
	for i in [1, 2]:
		variants.set(
			"player%d_knight" % i,
			variants.preset_knights[get_node("pick_knight/player%d" % i).get_text()]
		)
	print(variants.player1_knight)
	print(variants.player2_knight)
	get_tree().change_scene("res://main.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()

func build_player_buttons():
	for i in [1, 2]:
		var pick_button = get_node("pick_knight/player%d" % i)
		pick_button.clear()
		for key in variants.preset_knights:
			pick_button.add_item(key)