extends Node

onready var card1 = get_node("Card1")
onready var card2 = get_node("Card2")
onready var card3 = get_node("Card3")
onready var card4 = get_node("Card4")
onready var guide = get_node("FieldOffset/CardGuide")
onready var result = get_node("Result")
onready var remain = get_node("RemainTime")

var hand
var selected_card

func connect_ui_signals():
	input.connect("mouse_pressed", self, "pressed_outside_of_UI")
	card1.connect("gui_input", self, "ui_input_event", [true, card1])
	card2.connect("gui_input", self, "ui_input_event", [true, card2])
	card3.connect("gui_input", self, "ui_input_event", [true, card3])
	card4.connect("gui_input", self, "ui_input_event", [true, card4])

func update_changes(game):
	var player = game.Players[global.id]
	hand = player.Hand
	# update deck and energy
#	get_node("Next").set_texture(resource.icon[player.Next]["small"])
	get_node("Energy").set_value(player.Energy / 100)
	update_card_texture(player)
	update_remain_time(int(game.Frame))

	if game.has("Result"):
		global.config.set_value("match", global.id, null)
		global.save_config()
		input.disconnect("mouse_pressed", self, "pressed_outside_of_UI")
		result.show()
		result.show_result(game.Result)
		tcp.disconnect_server()

func pressed_outside_of_UI(pos):
	if selected_card and global.get_location(pos) == global.LOCATION_BLUE:
		use_card(pos)

func get_selected_card_id():
	if not selected_card:
		return 0
	return int(selected_card.get_name().right(1))

func update_card_texture(player):
	for i in range(1, 5):
		get_node("Card%d" % i).update(player.Energy, hand[i - 1])


func update_remain_time(frame):
	if frame > global.DOUBLE_AFTER:
		remain.add_color_override("font_color_shadow", Color(1, 0, 0, 1))
	var remainTime = global.PLAY_TIME - frame
	if remainTime < 0:
		remainTime += global.OVER_TIME
	remainTime /= 10
	remain.set_text("%d:%02d" % [remainTime / 60, remainTime % 60])

func toggle_card_focus(node, selected):
	selected_card = node
	node.grab_focus()
	if not selected:
		selected_card = null
		node.release_focus()

func use_card(pos=Vector2(0, 0)):
	tcp.send({
		"Use" : get_selected_card_id(),
		"Position" : {"X" : pos.x, "Y" : pos.y, },
	})
	toggle_card_focus(selected_card, false)

func press(is_card, node):
	if not is_card:
		add_unit_to_guide({"Name":node.name, "Position":{"X":0, "Y":0}})
		return

	toggle_card_focus(node, true)
	var name = hand[get_selected_card_id() - 1]
	if global.is_spell_card(name):
		add_spell_to_guide(name)
		return

	var card = {
		"Name" : name,
		"Team" : "",
		"Position" : { "X" : 0, "Y" : 0, },
	}
	for unit in global.get_structures_of_unit(card):
		add_unit_to_guide(unit)

func release(is_card, node):
	var pos = guide.position / 3
	release_guide()
	if not is_card:
		tcp.send({
			"Move" : int(node.get_name()),
			"Position" : { "X" : pos.x, "Y" : pos.y, },
		})
		return
	var name = hand[get_selected_card_id() - 1]
	var location = global.get_location(pos)
	if location != global.LOCATION_BLUE:
		if not global.is_spell_card(name):
			return
		if location != global.LOCATION_RED:
			return
	use_card(pos)

func ui_input_event(event, is_card, node):
	if event is InputEventMouseButton:
		if event.pressed:
			press(is_card, node)
		else:
			release(is_card, node)
	if event is InputEventMouseMotion:
		update_guide_position(event.global_position)

func add_spell_to_guide(name):
	var node = resource.effect.spell_indicator.instance()
	node.initialize(name)
	guide.add_child(node)
	
func add_unit_to_guide(unit):
	var name = unit.Name
	var node = resource.unit[name].instance()
	unit.Team = global.team
	node.initialize(unit)
	guide.add_child(node)
	node.transform_to_ui_node(Vector2(unit.Position.X, unit.Position.Y), Color(1, 1, 1, 0.5))

func update_guide_position(pos):
	pos = get_node("FieldOffset").to_local(pos) / 3
	var location = global.get_location(pos)
	if location == global.LOCATION_RED:
		var selected = get_selected_card_id()
		if selected <= 0 or not global.is_spell_card(hand[selected - 1]):
			pos.y = global.CARD_THRESHOLD_TOP
	guide.position = pos * 3
	guide.hide() if location in [global.LOCATION_UI, global.LOCATION_BASE] else guide.show()

func release_guide():
	guide.hide()
	guide.position = Vector2(0, 0)
	for child in guide.get_children():
		child.queue_free()