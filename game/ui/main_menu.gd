extends Control
	
func _ready():
	get_node("Background/blue_team").set_text("Blue Team : " + str(variants.blue_score) + " WIN")
	get_node("Background/red_team").set_text("Red Team : " + str(variants.red_score) + " WIN")
	get_node("Deck").hide()
	get_node("Shop").hide()
	if variants.preset_knights.size() <= 0:
		_on_HButtonArray_button_selected(0)
		get_node("HButtonArray").set_selected(0)
	set_process_input(true)

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