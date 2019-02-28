extends Node

var lobby setget set_lobby, get_lobby

func set_lobby(node):
	lobby = node

func get_lobby():
	assert(lobby != null)
	return lobby