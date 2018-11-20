extends Node

var cfg = config.GAME

func _enter_tree():
	get_node("game").cfg = cfg