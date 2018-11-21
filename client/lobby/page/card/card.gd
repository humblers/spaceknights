extends "res://lobby/page/page.gd"

const KNIGHT_SIDES = ["Center", "Left", "Right"]

var lobby
var pressed_card
var picked_card

var filter = "Troop"

var pressed
var picked
var tutor_mode
var deck_label
var deck_btns = {}
var knights = {}
var troops = {}
var containers = {}

func _ready():
	scroll_max_y = get_vertical_scrollable_control().rect_position.y
	var size_modifier = $PageMain/MarginContainer/VBoxContainer/BottomContainers
	size_modifier.connect("resized", self, "calc_scroll_threshold", [self, size_modifier.rect_size.y])
	for k in deck_btns:
		var btn = deck_btns[k]
		btn.connect("button_up", self, "button_up_deck_num", [btn])
	for k in knights:
		var btn = knights[k]
		btn.connect("button_up", self, "button_up_deck_item", [btn])
	for k in troops:
		var btn = troops[k]
		btn.connect("button_up", self, "button_up_deck_item", [btn])
	tutor_mode.connect("button_up", self, "go_to_tutor_mode")

func invalidate():
	var cur_mode = current_mode()
	var selected = user.DeckSelected
	deck_label.text = "%d" % (selected + 1)
	deck_btns[int(selected)].pressed = true

	var not_found_cards = stat.cards.keys()
	var found_cards = user.Cards.keys()
	var deck = user.Decks[selected]
	for i in range(KNIGHT_SIDES.size()):
		var name = deck.Knights[i]
		not_found_cards.erase(name)
		found_cards.erase(name)
		var btn = knights[KNIGHT_SIDES[i]]
		btn.invalidate(name, self, cur_mode == MODE_EDIT_TROOP)
	for i in range(deck.Troops.size()):
		var name = deck.Troops[i]
		not_found_cards.erase(name)
		found_cards.erase(name)
		troops[i].invalidate(name, self, cur_mode == MODE_EDIT_KNIGHT)
	for child in containers.founds.get_children():
		child.queue_free()
	for i in range(found_cards.size()):
		var name = found_cards[i]
		not_found_cards.erase(name)
		if filter != stat.units[stat.cards[name].Unit]["type"]:
			continue
		var item = $ResourcePreloader.get_resource("item").instance()
		containers.founds.add_child(item)
		item.invalidate(name, self)
	pressed.invalidate(pressed_card, self)
	picked.invalidate(picked_card, self)

	var is_edit = cur_mode in [MODE_EDIT_KNIGHT, MODE_EDIT_TROOP]
	if is_edit:
		get_vertical_scrollable_control().rect_position.y = scroll_max_y
	pressed.visible = pressed_card != null and not is_edit
	picked.visible = is_edit
	containers.lists.visible = not is_edit

func calc_scroll_threshold(control, org_size_y):
	scroll_min_y = org_size_y - control.rect_size.y

func current_mode():
	if not stat.cards.has(picked_card):
		return MODE_NORMAL
	var type = stat.units[stat.cards[picked_card].Unit].type
	if type == "Knight":
		return MODE_EDIT_KNIGHT
	elif type == "Troop":
		return MODE_EDIT_TROOP
	return null

func button_up_deck_num(btn):
	var pressed_num = int(btn.name[-1])
	var request = http.new_request(HTTPClient.METHOD_POST, "/edit/deck/select", {"num":pressed_num})
	var response = yield(request, "response")
	if not response[0]:
		http.handle_error(response[1].ErrMessage)
		return
	user.DeckSelected = pressed_num
	lobby.invalidate()

func button_up_deck_item(btn):
	if current_mode() == MODE_NORMAL:
		return
	var params = {
		"num": user.DeckSelected,
		"deck" : {"Knights": [], "Troops": []},
	}
	for side in KNIGHT_SIDES:
		var knight_btn = knights[side]
		params.deck.Knights.append(picked_card if knight_btn.name_ == btn.name_ else knight_btn.name_)
	for i in troops:
		var troop_btn = troops[i]
		params.deck.Troops.append(picked_card if troop_btn.name_ == btn.name_ else troop_btn.name_)
	var request = http.new_request(HTTPClient.METHOD_POST, "/edit/deck/set", params)
	var response = yield(request, "response")
	if not response[0]:
		http.handle_error(response[1].ErrMessage)
		return
	picked_card = null
	pressed_card = null
	user.Decks[params.num] = params.deck
	lobby.invalidate()

func set_pressed_card(btn):
	if current_mode() in [MODE_EDIT_KNIGHT, MODE_EDIT_TROOP]:
		return
	if pressed_card == btn.name_:
		pressed_card = null
		return
	pressed_card = btn.name_
	pressed.rect_global_position = btn.get_node("Position2D").global_position
	if user.CardInDeck(pressed_card):
		filter = stat.units[stat.cards[pressed_card].Unit]["type"]
	invalidate()

func set_picked_card(btn):
	picked_card = pressed_card
	invalidate()

func go_to_tutor_mode():
	var params = config.GAME.duplicate(true)
	var k = params.Players[0].Knights
	k.clear()
	for side in KNIGHT_SIDES:
		var knight_btn = knights[side]
		k.append({"Name":knight_btn.name_, "Level":0})
	var d = params.Players[0].Deck
	d.clear()
	for i in troops:
		var troop_btn = troops[i]
		d.append({"Name":troop_btn.name_, "Level":0})
	loading_screen.goto_scene("res://game/offline/tutor/tutor.tscn", {"cfg": params})

func _set_node_to_variant(node, var_name):
	self.set(var_name, node)

func _set_node_to_dictionary(node, var_name, key):
	self.get(var_name)[key] = node