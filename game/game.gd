extends Node

const ID = "alice"
const SESSION_ID = "test"

var HEIGHT
var WIDTH

func _ready():
	WIDTH = Globals.get("display/width")
	HEIGHT = Globals.get("display/height") - get_node("UI/Elixir").get_size().y
	kcp._connect("127.0.0.1", 9999)
	kcp.send({"Id": ID, "Token": ID})
	kcp.send({"SessionId": SESSION_ID})
	kcp.connect("packet_received", self, "update")
	input.connect("mouse_dragged", self, "send_player_input")
	input.connect("mouse_pressed", self, "show_deck")

func _exit_tree():
	kcp._disconnect()

func load_sprite(name, color):
	return load("res://" + name + "_" + color + ".png")

func get_position(team, x, y):
	if team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(WIDTH - x, HEIGHT - y)

func update(game):
	var team = "Home" if game.has("Home") else "Visitor"
	var player = game[team][ID]
	get_node("UI/Deck/Next").set_texture(load_sprite(player.Next, "blue"))
	for i in range(3):
		var node = get_node("UI/Deck/Card" + str(i + 1))
		var card = player.Hand[i]
		node.set_text(card)
		node.set_button_icon(load_sprite(card, "blue"))
	get_node("UI/Elixir").set_value(player.Elixir)
	get_node("UI/Elixir/Label").set_text(str(floor(player.Elixir/10)))
	
	for i in game.Units:
		var unit = game.Units[i]
		var layer = get_node(unit.Layer + "/YSort")
		if not layer.has_node(i):
			var node = Sprite.new()
			var color = "blue" if team == unit.Team else "red"
			node.set_texture(load_sprite(unit.Name, color))
			node.set_name(i)
			layer.add_child(node)
		layer.get_node(i).set_pos(get_position(team, unit.X, unit.Y))

func send_player_input(x):
	kcp.send({ "Move" : x })

func show_deck(pressed):
	if pressed:
		get_node("UI/Deck").hide()
	else:
		get_node("UI/Deck").show()

func _on_Card1_pressed():
	kcp.send({ "Use" : 1 })


func _on_Card2_pressed():
	kcp.send({ "Use" : 2 })


func _on_Card3_pressed():
	kcp.send({ "Use" : 3 })
