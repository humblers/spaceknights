extends Node

onready var card1 = get_node("Card1")
onready var card2 = get_node("Card2")
onready var card3 = get_node("Card3")
onready var card4 = get_node("Card4")
onready var result = get_node("Result")
onready var guide = get_node("CardGuide")

var hand
var knight_pos

func connect_ui_signals():
	card1.connect("pressed", self, "card_input_event", [card1])
	card2.connect("pressed", self, "card_input_event", [card2])
	card3.connect("pressed", self, "card_input_event", [card3])
	card4.connect("pressed", self, "card_input_event", [card4])
	result.connect("pressed", self, "back_to_lobby")

func update_changes(game):
	var player = game[global.team][global.id]
	hand = player.Hand
	# update deck and energy
	get_node("Next").set_texture(resource.icon[player.Next]["small"])
	get_node("Energy").set_value(player.Energy / 100)
	update_card_texture(game.Frame, player)

	if game.has("Result"):
		global.config.set_value("match", global.id, null)
		global.save_config()
		input.disconnect("mouse_pressed", self, "pressed_outside_of_UI")
		show_result(game.Result)
		tcp.disconnect_server()

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

func get_selected_card_id(node):
	return int(node.get_name().right(1))

func update_card_texture(frame, player):
	for i in range(1, 4):
		var node = get_node("Card" + str(i))
		var card = hand[i - 1]
		var postfix = "off"
		if player.Energy >= global.CARDS[card].cost:
			postfix = "on"
		node.set_normal_texture(resource.icon[card][postfix].normal)
	var state = "normal"
	var postfix = "on"
	if player.KnightIdleTo > frame:
		state = "pressed"
	elif player.Energy < global.CARDS["shoot"].cost:
		postfix = "off"
	card4.set_normal_texture(resource.icon["shoot"][postfix][state])

func update_knight_position(id, pos):
	knight_pos = pos

func card_input_event(node):
	var pos = knight_pos
	pos.y = global.MAP.height - pos.y
	if global.team == "Visitor":
		pos.x = global.MAP.width - pos.x
	tcp.send({
		"Use" : get_selected_card_id(node),
		"Position" : {"X":pos.x, "Y":pos.y},
	})