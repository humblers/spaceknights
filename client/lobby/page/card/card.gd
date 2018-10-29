extends "res://lobby/page/page.gd"

var pressed_card
var picked_card

var filter = "Troop"

onready var deck_label = $PageMain/MarginContainer/VBoxContainer/Decks/HBoxContainer/Current
onready var deck_btns = [
	$PageMain/MarginContainer/VBoxContainer/Decks/HBoxContainer/Deck0,
	$PageMain/MarginContainer/VBoxContainer/Decks/HBoxContainer/Deck1,
	$PageMain/MarginContainer/VBoxContainer/Decks/HBoxContainer/Deck2,
	$PageMain/MarginContainer/VBoxContainer/Decks/HBoxContainer/Deck3,
	$PageMain/MarginContainer/VBoxContainer/Decks/HBoxContainer/Deck4,
]

onready var knights = [
	$PageMain/MarginContainer/VBoxContainer/Knights/Center/Item,
	$PageMain/MarginContainer/VBoxContainer/Knights/Left/Item,
	$PageMain/MarginContainer/VBoxContainer/Knights/Right/Item,
]

onready var troops = [
	$PageMain/MarginContainer/VBoxContainer/Troops/VBoxContainer/Item,
	$PageMain/MarginContainer/VBoxContainer/Troops/VBoxContainer2/Item,
	$PageMain/MarginContainer/VBoxContainer/Troops/VBoxContainer2/Item2,
	$PageMain/MarginContainer/VBoxContainer/Troops/VBoxContainer3/Item,
	$PageMain/MarginContainer/VBoxContainer/Troops/VBoxContainer3/Item2,
	$PageMain/MarginContainer/VBoxContainer/Troops/VBoxContainer4/Item,
]

onready var containers = {
	"lists": $PageMain/MarginContainer/VBoxContainer/BottomContainers/Lists,
	"founds": $PageMain/MarginContainer/VBoxContainer/BottomContainers/Lists/CenterContainer/Founds,
	"notfounds": $PageMain/MarginContainer/VBoxContainer/BottomContainers/Lists/CenterContainer/NotFounds,
}

onready var pressed = $PageMain/MarginContainer/Control/Pressed
onready var picked = $PageMain/MarginContainer/VBoxContainer/BottomContainers/CenterContainer/Picked

func _ready():
	scroll_max_y = get_vertical_scrollable_control().rect_position.y
	var size_modifier = $PageMain/MarginContainer/VBoxContainer/BottomContainers
	size_modifier.connect("resized", self, "calc_scroll_threshold", [self, size_modifier.rect_size.y])
	for btn in deck_btns:
		btn.connect("button_up", self, "button_up_deck_num", [btn])
	for btn in knights:
		btn.connect("button_up", self, "button_up_deck_item", [btn])
	for btn in troops:
		btn.connect("button_up", self, "button_up_deck_item", [btn])

func invalidate():
	var cur_mode = current_mode()
	var selected = user.DeckSelected
	deck_label.text = "%d" % (selected + 1)
	deck_btns[selected].pressed = true

	var not_found_cards = stat.cards.keys()
	var found_cards = user.Cards.keys()
	var deck = user.Decks[selected]
	for i in range(deck.Knights.size()):
		var name = deck.Knights[i]
		not_found_cards.erase(name)
		found_cards.erase(name)
		knights[i].invalidate(name, self, cur_mode == MODE_EDIT_TROOP)
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

func sort_knight(a, b):
	if stat.units[stat.cards[b].Unit]["type"] == "Knight":
		return false
	return true

func sort_troops(a, b):
	if stat.units[stat.cards[b].Unit]["type"] == "Troops":
		return false
	return true

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
	invalidate()

func button_up_deck_item(btn):
	if current_mode() == MODE_NORMAL:
		return
	var params = {
		"num": user.DeckSelected,
		"deck" : {"Knights": [], "Troops": []},
	}
	for knight_btn in knights:
		params.deck.Knights.append(picked_card if knight_btn.name_ == btn.name_ else knight_btn.name_)
	for troop_btn in troops:
		params.deck.Troops.append(picked_card if troop_btn.name_ == btn.name_ else troop_btn.name_)
	var request = http.new_request(HTTPClient.METHOD_POST, "/edit/deck/set", params)
	var response = yield(request, "response")
	if not response[0]:
		http.handle_error(response[1].ErrMessage)
		return
	picked_card = null
	pressed_card = null
	user.Decks[params.num] = params.deck
	invalidate()

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

func get_vertical_scrollable_control():
	return $PageMain/MarginContainer