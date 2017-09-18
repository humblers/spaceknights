extends Node

onready var card1 = get_node("Card1")
onready var card2 = get_node("Card2")
onready var card3 = get_node("Card3")
onready var id = http_lobby.get_var("uid")

func _ready():
	kcp.connect("packet_received", self, "update")
	card1.connect("pressed", self, "use_card", [1])
	card2.connect("pressed", self, "use_card", [2])
	card3.connect("pressed", self, "use_card", [3])
	input.connect("mouse_dragged", self, "send_player_input")

func load_icon(name):
	return load("res://icon/" + name + ".png")

func update(game):
	# update deck and energy
	var my_team = "Home" if game.has("Home") else "Visitor"
	var player = game[my_team][id]
	get_node("Next").set_texture(load_icon(player.Next))
	for i in range(1, 4):
		var node = get_node("Card" + str(i))
		var card = player.Hand[i - 1]
		node.set_normal_texture(load_icon(card))
	get_node("Energy").set_value(player.Energy)

	if game.has("Winner"):
		var node = get_node("Winner")
		node.set_text("Winner : " + game.Winner)
		node.show()
		card1.disconnect("pressed", self, "use_card")
		card2.disconnect("pressed", self, "use_card")
		card3.disconnect("pressed", self, "use_card")
		input.disconnect("mouse_dragged", self, "send_player_input")
		input.connect("mouse_pressed", self, "back_to_lobby")

func use_card(i):
	kcp.send({ "Use" : i})

func send_player_input(x):
	kcp.send({ "Move" : x })

func back_to_lobby(pressed):
	if pressed:
		get_tree().change_scene("res://lobby.tscn")