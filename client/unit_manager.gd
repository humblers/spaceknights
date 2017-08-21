extends Node

func _ready():
	pass

func load_unit_texture(name, color, postfix=null):
	var path = "res://unit/" + name + "_" + color
	if postfix:
		path += "_" + postfix
	path += ".png"
	return load(path)

func load_unit(name, color):
	var unit = load("res://unit/" + name + ".tscn")
	if unit:
		return unit
	var multiple_texture_nodes = { 
		"cannon" : ["bot", "top"],
	}
	var node
	if multiple_texture_nodes.has(name):
		node = Node2D.new()
		for postfix in multiple_texture_nodes[name]:
			var sp = Sprite.new()
			sp.set_texture(load_unit_texture(name, color, postfix))
			node.add_child(sp)
		return node
	node = Sprite.new()
	node.set_texture(load_unit_texture(name, color))
	return node

func play(unit, team, anim):
	pass