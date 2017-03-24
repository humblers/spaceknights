extends Control

func _ready():
	get_node("blue_team").set_text("Blue Team : " + str(start.blue_score) + " WIN")
	get_node("red_team").set_text("Red Team : " + str(start.red_score) + " WIN")
	set_process_input(true)
	
func _on_play_pressed():
	get_tree().change_scene("res://ui/main_menu.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_exit_popup"):
		_on_play_pressed()
