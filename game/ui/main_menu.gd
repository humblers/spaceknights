extends Control

func _ready():
	get_node("blue_team").set_text("Blue Team : " + str(Globals.get("blue_result")) + " WIN")
	get_node("red_team").set_text("Red Team : " + str(Globals.get("red_result")) + " WIN")
	set_process_unhandled_input(true)
	
func _on_play_pressed():
	get_tree().change_scene("res://main.tscn")

func _unhandled_input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()

func _on_turret_fixed_pressed():
	start.player1_skiil_queue.append(constants.TURRET_FIXED_TYPE)
	update_skill_queue()

func _on_turret_forward_pressed():
	start.player1_skiil_queue.append(constants.TURRET_FORWARD_TYPE)
	update_skill_queue()

func update_skill_queue():
	pass
