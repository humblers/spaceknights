extends Node

onready var card1 = get_node("Card1")
onready var card2 = get_node("Card2")
onready var card3 = get_node("Card3")
onready var winner = get_node("Winner")
onready var guide = get_node("CardGuide")

var hand

func connect_ui_signals():
	input.connect("mouse_dragged", self, "move")
	card1.connect("pressed", self, "press_card", [1])
	card2.connect("pressed", self, "press_card", [2])
	card3.connect("pressed", self, "press_card", [3])
	card1.connect("released", self, "release_card", [1])
	card2.connect("released", self, "release_card", [2])
	card3.connect("released", self, "release_card", [3])
	card1.connect("mouse_exit", self, "cancel_card")
	card2.connect("mouse_exit", self, "cancel_card")
	card3.connect("mouse_exit", self, "cancel_card")
	winner.connect("pressed", self, "back_to_lobby")

func load_icon(name, postfix):
	return load("res://icon/%s_%s.png" % [name, postfix])

func update_changes(game):
	var player = game[global.team][global.id]
	hand = player.Hand
	# update deck and energy
	get_node("Next").set_texture(load_icon(player.Next, "small"))
	for i in range(1, 4):
		var node = get_node("Card" + str(i))
		var card = hand[i - 1]
		var postfix = "off"
		if player.Energy >= global.CARDS[card].cost:
			postfix = "on"
		node.set_normal_texture(load_icon(card, postfix))
	get_node("Energy").set_value(player.Energy)

	if game.has("Winner"):
		global.config.set_value("match", global.id, null)
		global.save_config()
		input.disconnect("mouse_dragged", self, "move")
		show_winner(game)

func press_card(i):
	guide.show(hand[i - 1])

func release_card(i):
	kcp.send({ 
	"Use" : {
		"Index" : i,
		"Point" : guide.get_release_point(),
		}
	})
	guide.hide()

func cancel_card():
	guide.hide()

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