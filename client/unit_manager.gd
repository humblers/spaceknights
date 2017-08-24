extends Node

var WIDTH
var HEIGHT

func _ready():
	pass

func get_position(team, x, y):
	if team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(WIDTH - x, HEIGHT - y)

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
	var label = Label.new()
	label.set_name("HP")
	var path = "res://unit/" + name + ".tscn"
	var unit 
	if File.new().file_exists(path):
		unit = load(path).instance()
	if not unit:
		unit = load_unit_from_resource(name, color)
	unit.add_child(label)
	return unit

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

func apply_state(node, unit, frame, team, color):
	node.set_pos(get_position(team, unit.Position.X, unit.Position.Y))
	node.get_node("HP").set_text(String(unit.Hp))
	var action = "move"
	if unit.has("LastHit") and frame <= unit.LastHit + unit.HitSpeed:
		action = "attack"
	change_action(node, color, action)

func update(game_node, units, frame, team):
	# delete dead unit nodes
	for node in game_node.get_node("Ground").get_children():
		if node.get_name() == "Background":
			continue
		if not units.has(node.get_name()):
			node.queue_free()

	for node in game_node.get_node("Air").get_children():
		if not units.has(node.get_name()):
			node.queue_free()

	# update unit nodes
	for i in units:
		var unit = units[i]
		var layer = game_node.get_node(unit.Layer)
		var color = "blue" if team == unit.Team else "red"
		var node
		if not layer.has_node(i):
			node = load_unit(unit.Name, color)
			node.set_name(i)
			layer.add_child(node)
		apply_state(layer.get_node(i), unit, frame, team, color)
