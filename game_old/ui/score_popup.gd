extends Control

var score
var overall

func _ready():
	if variants.blue_life <= 0:
		score = (variants.red_life - variants.blue_life) * 1000
		get_node("winner").set_text("RED WIN! = KNIGHT")
	elif variants.red_life <= 0:
		score = (variants.blue_life - variants.red_life) * 1000
		get_node("winner").set_text("BLUE WIN! = KNIGHT ")
	
	if variants.blue_life <= 0 || variants.red_life <= 0:
		get_node("score").set_text("Score : 0" + str(score))
		get_node("blue_team").set_text("Blue LIFE : " + str(variants.blue_life))
		get_node("red_team").set_text("Red LIFE : " + str(variants.red_life))

	if variants.blue_life > 0 && variants.red_life > 0:
		if variants.blue_hp > variants.red_hp:
			get_node("winner").set_text("BLUE WIN! = MOTHER")
			score = variants.blue_hp - variants.red_hp
		else:
			get_node("winner").set_text("RED WIN! = MOTHER")
			score = variants.red_hp - variants.blue_hp
		get_node("score").set_text("Score : 0" + str(score))
		get_node("blue_team").set_text("Blue Team's HP : " + str(variants.blue_hp))
		get_node("red_team").set_text("Red Team's HP : " + str(variants.red_hp))
	
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
	variants.gameover = false
	get_tree().change_scene("res://ui/main_menu.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_exit_popup"):
		_on_play_pressed()
