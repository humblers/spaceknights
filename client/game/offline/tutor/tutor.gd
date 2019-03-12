extends Node

var cfg = config.GAME

func _enter_tree():
	get_node("game").cfg = cfg

func _physics_process(delta):
	var game = get_node("game")
	if game.frame % game.frame_per_step == 0:
		if game.Over():
			set_physics_process(false)
			if game.score("Blue") > game.score("Red"):
				user.request_new_chest = true
