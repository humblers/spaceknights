
extends Control

func _ready():
	get_node("blue_team").set_text("Blue Team : " + str(Globals.get("blue_result")) + " WIN")
	get_node("red_team").set_text("Red Team : " + str(Globals.get("red_result")) + " WIN")
	
func _on_play_pressed():

	get_tree().change_scene("res://main.tscn")
