extends Node

onready var card1 = get_node("Card1")
onready var card2 = get_node("Card2")
onready var card3 = get_node("Card3")
onready var winner = get_node("Winner")

var id
var team

func _ready():
	id = http_lobby.get_var("uid")
	kcp.connect("packet_received", self, "update")
	input.connect("mouse_dragged", self, "move")
	card1.connect("pressed", self, "use_card", [1])
	card2.connect("pressed", self, "use_card", [2])
	card3.connect("pressed", self, "use_card", [3])
	winner.connect("pressed", self, "back_to_lobby")

func load_icon(name):
	return load("res://icon/" + name + ".png")

func update(game):
	# update deck and energy
	team = "Home" if game.has("Home") else "Visitor"
	var player = game[team][id]
	get_node("Next").set_texture(load_icon(player.Next))
	for i in range(1, 4):
		var node = get_node("Card" + str(i))
		var card = player.Hand[i - 1]
		node.set_normal_texture(load_icon(card))
	get_node("Energy").set_value(player.Energy)

	if game.has("Winner"):
		input.disconnect("mouse_dragged", self, "move")
		show_winner(game)

func use_card(i):
	kcp.send({ "Use" : i})

func move(x):
	kcp.send({ "Move" : x })

func back_to_lobby():
	get_tree().change_scene("res://lobby.tscn")

func show_winner(game):
	winner.set_text("You " + ("Win" if team == game.Winner else "Lose"))
	winner.show()