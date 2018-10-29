extends "res://lobby/page/page.gd"

var toggled_extra_card
var picked_card

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

onready var tabs = {
	"troops" : $PageMain/MarginContainer/VBoxContainer/Tab/HBoxContainer/Troops,
	"knights" : $PageMain/MarginContainer/VBoxContainer/Tab/HBoxContainer/Knights,
}

onready var containers = {
	"mode_edit": $PageMain/MarginContainer/VBoxContainer/BottomContainers/ModeEdit,
	"mode_normal": $PageMain/MarginContainer/VBoxContainer/BottomContainers/ModeNormal,
	"founds": $PageMain/MarginContainer/VBoxContainer/BottomContainers/ModeNormal/CenterContainer/Founds,
	"notfounds": $PageMain/MarginContainer/VBoxContainer/BottomContainers/ModeNormal/NotFounds,
	"extra": $PageMain/MarginContainer/VBoxContainer/BottomContainers/ExtraButtonHolder,
}

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
		var item = $ResourcePreloader.get_resource("item").instance()
		containers.founds.add_child(item)
		item.invalidate(name, self)

	var is_edit = cur_mode in [MODE_EDIT_KNIGHT, MODE_EDIT_TROOP]
	containers.mode_edit.visible = is_edit
	containers.mode_normal.visible = not is_edit
	containers.extra.visible = not is_edit
	tabs.troops.visible = not is_edit
	tabs.knights.visible = not is_edit

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
	user.Decks[params.num] = params.deck
	invalidate()

func toggle_extra_btns(btn):
	for child in containers.extra.get_children():
		child.queue_free()
	if toggled_extra_card == btn.name_:
		toggled_extra_card = null
		return
	toggled_extra_card = btn.name_
	var extra_btn = $ResourcePreloader.get_resource("extra_btns").instance()
	containers.extra.add_child(extra_btn)
	extra_btn.rect_global_position = btn.extra_btn_global_position()
	extra_btn.get_node("Use").connect("button_up", self, "pick_card", [extra_btn])

func pick_card(btn):
	picked_card = toggled_extra_card
	btn.queue_free()
	for child in containers.mode_edit.get_children():
		child.queue_free()
	var item = $ResourcePreloader.get_resource("item").instance()
	containers.mode_edit.add_child(item)
	item.invalidate(picked_card, self)
	invalidate()

func get_vertical_scrollable_control():
	return $PageMain/MarginContainer