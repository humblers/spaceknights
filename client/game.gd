extends Node

onready var WIDTH = Globals.get("display/width")
onready var HEIGHT = Globals.get("display/height") - get_node("Ground/Background").get_texture().get_size().height
onready var card0 = get_node("UI/Card0")
onready var card1 = get_node("UI/Card1")
onready var card2 = get_node("UI/Card2")

var id
var session_id
var team

signal game_over(winner)

func _ready():
	id = http_lobby.get_var("uid")
	session_id = http_lobby.get_var("game_sessionid")
	kcp._connect(http_lobby.get_var("game_host"), 9999)
	kcp.send({"Id": id, "Token": id})
	kcp.send({"SessionId": session_id})
	kcp.connect("packet_received", self, "update")
	input.connect("mouse_dragged", self, "send_player_input")
	connect("game_over", self, "on_game_over")

func on_game_over(winner):
	input.disconnect("mouse_dragged", self, "send_player_input")
	card0.disconnect("pressed", self, "use_card")
	card1.disconnect("pressed", self, "use_card")
	card2.disconnect("pressed", self, "use_card")
	kcp._disconnect()
	var node = get_node("UI/Winner")
	node.set_text("Winner : " + winner)
	node.show()

func load_icon(name):
	return load("res://icon/" + name + ".png")

func load_unit(name, color):
	return load("res://unit/" + name + "_" + color + ".png")

func get_position(team, x, y):
	if team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(WIDTH - x, HEIGHT - y)

func update(game):
	# update deck and energy
	team = "Home" if game.has("Home") else "Visitor"
	var player = game[team][id]
	get_node("UI/Next").set_texture(load_icon(player.Next))
	for i in range(3):
		var node = get_node("UI/Card" + str(i))
		var card = player.Hand[i]
		node.set_normal_texture(load_icon(card))
	get_node("UI/Energy").set_value(player.Energy)
	
	# delete dead unit nodes
	for node in get_node("Ground").get_children():
		if node.get_name() == "Background":
			continue
		if not game.Units.has(node.get_name()):
			node.queue_free()

	for node in get_node("Air").get_children():
		if not game.Units.has(node.get_name()):
			node.queue_free()

	# update unit nodes
	for i in game.Units:
		var unit = game.Units[i]
		var layer = get_node(unit.Layer)
		if not layer.has_node(i):
			var node = Sprite.new()
			var color = "blue" if team == unit.Team else "red"
			node.set_texture(load_unit(unit.Name, color))
			node.set_name(i)
			layer.add_child(node)
		layer.get_node(i).set_pos(get_position(team, unit.Position.X, unit.Position.Y))
	
	if game.has("Winner"):
		emit_signal("game_over", game.Winner)

func send_player_input(x):
	kcp.send({ "Move" : x })

func use_card(index):
	kcp.send({ "Use" : index })