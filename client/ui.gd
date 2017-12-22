extends Node

onready var card1 = get_node("Card1")
onready var card2 = get_node("Card2")
onready var card3 = get_node("Card3")
onready var result = get_node("Result")

var hand
var knight_pos

func connect_ui_signals():
	card1.connect("pressed", self, "card_input_event", [card1])
	card2.connect("pressed", self, "card_input_event", [card2])
	card3.connect("pressed", self, "card_input_event", [card3])
	input.connect("second_touched", self, "make_event_local")
	result.connect("pressed", self, "back_to_lobby")

func update_changes(game):
	var player = game[global.team][global.id]
	hand = player.Hand
	# update deck and energy
	get_node("Next").set_texture(resource.icon[player.Next]["small"])
	get_node("Energy").set_value(player.Energy / 100)
	update_card_texture(game.Frame, player)
	delete_spell_indicator()
	create_spell_indicator()

	if game.has("Result"):
		global.config.set_value("match", global.id, null)
		global.save_config()
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

func create_spell_indicator():
	for i in range(1, 4):
		var card = hand[i - 1]
		var node_name = "Indicator%d" % [i - 1]
		if not global.is_spell_card(card):
			continue
		if get_node("Indicators").has_node(node_name):
			continue
		var node = resource.effect.spell_indicator.instance()
		node.initialize(card, knight_pos)
		node.set_name(node_name)
		get_node("Indicators").add_child(node)

func update_spell_indicator():
	for i in range(1, 4):
		var card = hand[i - 1]
		if global.is_spell_card(card):
			get_node("Indicators/Indicator%d"  % [i - 1]).set_position(knight_pos)

func delete_spell_indicator():
	for i in range(1, 4):
		var card = hand[i - 1]
		var node_name = "Indicators/Indicator%d" % [i - 1]
		if has_node(node_name):
			if global.is_spell_card(card) and get_node(node_name).name == card:
				continue
			get_node(node_name).queue_free()

func update_knight_position(id, pos):
	knight_pos = pos
	update_spell_indicator()

func make_event_local(event):
	for i in range(1, 4):
		var node = get_node("Card" + str(i))
		var transformed = node.make_input_local(event)
		if node.get_item_rect().has_point(transformed.pos):
			card_input_event(node)

func card_input_event(node):
	tcp.send({
		"Use" : get_selected_card_id(node),
	})