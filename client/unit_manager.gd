extends Node

func _ready():
	pass

func load_unit_texture(name, color, postfix=null):
	var path = "res://unit/" + name + "_" + color
	if postfix:
		path += "_" + postfix
	path += ".png"
	return load(path)

func load_unit_from_resource(name, color):
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

func load_unit(name, color):
	var path = "res://unit/" + name + ".tscn"
	if not File.new().file_exists(path):
		return load_unit_from_resource(name, color)
	var unit = load(path).instance()
	if unit != null:
		return unit
	return load_unit_from_resource(name, color)

func change_action(unit, color, action):
	if not unit.has_node("anims"):
		return
	var animspr = unit.get_node("anims")
	var animstr = color + "_" + action
	if animspr.get_animation() == animstr:
		return
	var sprframes = animspr.get_sprite_frames()
	if not sprframes or not sprframes.has_animation(animstr):
		return
	animspr.set_animation(animstr)