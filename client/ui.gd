extends Node

onready var card1 = get_node("Card1")
onready var card2 = get_node("Card2")
onready var card3 = get_node("Card3")
onready var winner = get_node("Winner")

func _ready():
	input.connect("mouse_dragged", self, "move")
	card1.connect("pressed", self, "use_card", [1])
	card2.connect("pressed", self, "use_card", [2])
	card3.connect("pressed", self, "use_card", [3])
	winner.connect("pressed", self, "back_to_lobby")

func update_changes(game):
	var player = game[global.team][global.id]
	# update deck and energy
	get_node("Next").set_texture(load_icon(player.Next))
	for i in range(1, 4):
		var node = get_node("Card" + str(i))
		var card = player.Hand[i - 1]
		node.set_normal_texture(load_icon(card))
	get_node("Energy").set_value(player.Energy)

	if game.has("Winner"):
		input.disconnect("mouse_dragged", self, "move")
		show_winner(game)

func load_icon(name):
	return load("res://icon/" + name + ".png")

func use_card(i):
	kcp.send({ "Use" : i})

func move(x):
	kcp.send({ "Move" : x })

func back_to_lobby():
	get_tree().change_scene("res://lobby.tscn")

func show_winner(game):
	var text
	if game.Winner == "Draw":
		text = "Draw"
	elif game.Winner == global.team:
		text = "You Win"
	else:
		text = "You Lose"
	winner.set_text(text)
	winner.show()