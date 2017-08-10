extends Node

var HEIGHT
var WIDTH

var id
var session_id

func _ready():
	WIDTH = Globals.get("display/width")
	HEIGHT = Globals.get("display/height") - get_node("Ground/YSort/Background").get_texture().get_size().height
	id = http_lobby.get_var("uid")
	session_id = http_lobby.get_var("game_sessionid")
	kcp._connect(http_lobby.get_var("game_host"), 9999)
	kcp.send({"Id": id, "Token": id})
	kcp.send({"SessionId": session_id})
	kcp.connect("packet_received", self, "update")
	input.connect("mouse_dragged", self, "send_player_input")

func _exit_tree():
	kcp._disconnect()

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
	var team = "Home" if game.has("Home") else "Visitor"
	var player = game[team][id]
	get_node("UI/Next").set_texture(load_icon(player.Next))
	for i in range(3):
		var node = get_node("UI/Card" + str(i + 1))
		var card = player.Hand[i]
		node.set_normal_texture(load_icon(card))
	get_node("UI/Energy").set_value(player.Energy)
	
	for i in game.Units:
		var unit = game.Units[i]
		var layer = get_node(unit.Layer + "/YSort")
		if not layer.has_node(i):
			var node = Sprite.new()
			var color = "blue" if team == unit.Team else "red"
			node.set_texture(load_unit(unit.Name, color))
			node.set_name(i)
			layer.add_child(node)
		layer.get_node(i).set_pos(get_position(team, unit.Position.X, unit.Position.Y))

func send_player_input(x):
	kcp.send({ "Move" : x })

func _on_Card1_pressed():
	kcp.send({ "Use" : 1 })

func _on_Card2_pressed():
	kcp.send({ "Use" : 2 })

func _on_Card3_pressed():
	kcp.send({ "Use" : 3 })
