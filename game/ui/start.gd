extends Node

export var player1_skiil_queue = []
export var player2_skill_queue = []

func _ready():
	Globals.set("blue_result", 0)
	Globals.set("red_result", 0)
	get_tree().change_scene("res://ui/main_menu.tscn")