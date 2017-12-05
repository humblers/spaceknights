extends Node

const CARD_THRESHOLD_TOP = 310
const LOCATION_UI = 0
const LOCATION_BASE = 1
const LOCATION_BLUE = 2
const LOCATION_RED = 3

onready var card1 = get_node("Card1")
onready var card2 = get_node("Card2")
onready var card3 = get_node("Card3")
onready var card4 = get_node("Card4")
onready var card5 = get_node("Card5")
onready var result = get_node("Result")
onready var guide = get_node("CardGuide")

var hand
var selected_card

func connect_ui_signals():
	input.connect("mouse_pressed", self, "pressed_outside_of_UI")
	card1.connect("input_event", self, "card_input_event", [card1])
	card2.connect("input_event", self, "card_input_event", [card2])
	card3.connect("input_event", self, "card_input_event", [card3])
	card4.connect("input_event", self, "card_input_event", [card4])
	card5.connect("input_event", self, "card_input_event", [card5])
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

func get_location(pos):
	if pos.y > global.MAP.height:
		return LOCATION_UI
	if pos.y < CARD_THRESHOLD_TOP:
		return LOCATION_RED
	return LOCATION_BLUE

func pressed_outside_of_UI(pos):
	if selected_card and get_location(pos) == LOCATION_BLUE:
		use_card(pos)

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

func get_selected_card_id():
	if not selected_card:
		return 0
	return int(selected_card.get_name().right(1))

func update_card_texture(frame, player):
	for i in range(1, 5):
		var node = get_node("Card" + str(i))
		var card = hand[i - 1]
		var postfix = "off"
		if player.Energy >= global.CARDS[card].cost:
			postfix = "on"
		node.set_normal_texture(resource.icon[card][postfix].normal)
		node.set_focused_texture(resource.icon[card][postfix].pressed)
	var state = "normal"
	var postfix = "on"
	if player.KnightShotRefuse > frame:
		state = "pressed"
	elif player.Energy < global.CARDS["shoot"].cost:
		postfix = "off"
	card5.set_normal_texture(resource.icon["shoot"][postfix][state])

func toggle_card_focus(node, selected):
	assert(node != null)
	selected_card = node
	node.grab_focus()
	if not selected:
		selected_card = null
		node.release_focus()

func use_card(pos=Vector2(0, 0)):
	pos.y = global.MAP.height - pos.y
	if global.team == "Visitor":
		pos.x = global.MAP.width - pos.x
	var index = get_selected_card_id()
	tcp.send({
		"Use" : {
			"Index" : index,
			"Position" : {"X":pos.x, "Y":pos.y},
		}
	})
	toggle_card_focus(selected_card, false)

func press_card(node):
	toggle_card_focus(node, true)
	var id = get_selected_card_id()
	if global.is_instantly_use_card(hand[id - 1]):
		use_card()
		return
	var card = hand[id - 1]
	var units = global.get_structures_of_unit( {
		"Name" : card,
		"Team" : "",
		"Position" : {
			"X" : 0, "Y" : 0,
		},
	} )
	for unit in units:
		unit.Team = global.team
		var name = unit.Name
		var node = resource.unit[name].instance()
		node.initialize(unit)
		guide.add_child(node)
		node.transform_to_guide_node(Vector2(unit.Position.X, unit.Position.Y))

func release_card():
	var pos = guide.get_pos()
	var location = get_location(pos)
	if location == LOCATION_BLUE:
		use_card(pos)
	deactivate_guide()

func card_input_event(event, node):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.pressed:
			press_card(node)
		else:
			release_card()

	if event.type == InputEvent.MOUSE_MOTION:
		var pos = event.global_pos
		var location = get_location(pos)
		if location == LOCATION_RED:
			pos.y = CARD_THRESHOLD_TOP
		guide.set_pos(pos)
		guide.hide() if location in [LOCATION_UI, LOCATION_BASE] else guide.show()

func deactivate_guide():
	guide.hide()
	guide.set_pos(Vector2(0, 0))
	for child in guide.get_children():
		child.queue_free()