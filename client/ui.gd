extends Node

onready var card1 = get_node("Card1")
onready var card2 = get_node("Card2")
onready var card3 = get_node("Card3")
onready var result = get_node("Result")
onready var guide = get_node("CardGuide")

var hand

func connect_ui_signals():
	input.connect("mouse_pressed", self, "move")
	card1.connect("pressed", self, "press_card", [1])
	card2.connect("pressed", self, "press_card", [2])
	card3.connect("pressed", self, "press_card", [3])
	card1.connect("released", self, "release_card", [1])
	card2.connect("released", self, "release_card", [2])
	card3.connect("released", self, "release_card", [3])
	card1.connect("mouse_exit", self, "cancel_card")
	card2.connect("mouse_exit", self, "cancel_card")
	card3.connect("mouse_exit", self, "cancel_card")
	result.connect("pressed", self, "back_to_lobby")

func update_changes(game):
	var player = game[global.team][global.id]
	hand = player.Hand
	# update deck and energy
	get_node("Next").set_texture(resource.icon[player.Next]["small"])
	for i in range(1, 4):
		var node = get_node("Card" + str(i))
		var card = hand[i - 1]
		var postfix = "off"
		if player.Energy >= global.CARDS[card].cost:
			postfix = "on"
		node.set_normal_texture(resource.icon[card][postfix])
	get_node("Energy").set_value(player.Energy / 100)

	if game.has("Result"):
		global.config.set_value("match", global.id, null)
		global.save_config()
		input.disconnect("mouse_pressed", self, "move")
		show_result(game.Result)
		tcp.disconnect_server()

func use_card(i):
	tcp.send({
	"Use" : {
		"Index" : i,
		"Point" : guide.get_release_point(),
		}
	})

func press_card(i):
	if global.is_spell_card(hand[i - 1]):
		use_card(i)
		return
	guide.show(hand[i - 1])

func release_card(i):
	if not global.is_spell_card(hand[i - 1]):
		use_card(i)
	guide.hide()

func cancel_card():
	guide.hide()

func move(pos):
	var maxY = global.MAP.height
	var minY = global.MAP.height - global.MOTHERSHIP_BASE_HEIGHT
	if pos.y < maxY && pos.y > minY:
		tcp.send({ "Move" : pos.x })

func back_to_lobby():
	get_tree().change_scene("res://lobby.tscn")

func show_result(data):
	var winner
	if data.Winner == "Draw":
		winner = "Draw"
	elif data.Winner == global.team:
		winner = "You Win"
	else:
		winner = "You Lose"
	
	var stats = ""
	stats += to_string(data.Stats, global.team) + "\n"
	stats += to_string(data.Stats, "Visitor" if global.team == "Home" else "Home")
	
	result.get_node("Label").set_text(winner + "\n\n" + stats)
	result.show()

func to_string(stats, team):
	var text = "[MyTeam]" if team == global.team else "[EnemyTeam]"
	text += "\n"
	var stat = stats[team]
	for key in stat:
		text += key + ": " + str(stat[key]) + "\n"
	return text
