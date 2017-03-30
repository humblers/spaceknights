extends Control

var score
var overall

func _ready():
	if start.blue_life <= 0:
		score = (start.red_life - start.blue_life) * 1000
		get_node("winner").set_text("RED WIN! = KNIGHT")
	elif start.red_life <= 0:
		score = (start.blue_life - start.red_life) * 1000
		get_node("winner").set_text("BLUE WIN! = KNIGHT ")
	
	if start.blue_life <= 0 || start.red_life <= 0:
		get_node("score").set_text("Score : 0" + str(score))
		get_node("blue_team").set_text("Blue LIFE : " + str(start.blue_life))
		get_node("red_team").set_text("Red LIFE : " + str(start.red_life))

	if start.blue_life > 0 && start.red_life > 0:
		if start.blue_hp > start.red_hp:
			get_node("winner").set_text("BLUE WIN! = MOTHER")
			score = start.blue_hp - start.red_hp
		else:
			get_node("winner").set_text("RED WIN! = MOTHER")
			score = start.red_hp - start.blue_hp
		get_node("score").set_text("Score : 0" + str(score))
		get_node("blue_team").set_text("Blue Team's HP : " + str(start.blue_hp))
		get_node("red_team").set_text("Red Team's HP : " + str(start.red_hp))
	
	if score > 1500:
		overall = "Perfect Win!!!"
	elif score > 1000:
		overall = "Excellent Win!!!"
	elif score > 500:
		overall = "Great Win!!!"
	else:
		overall = "Barely Win!!!"
	get_node("overall").set_text(overall)
	set_process_input(true)
	
func _on_play_pressed():
	start.gameover = false
	get_tree().change_scene("res://ui/main_menu.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_exit_popup"):
		_on_play_pressed()
