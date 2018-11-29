extends "res://lobby/page/page.gd"

const MODE_EDIT_KNIGHT = "EDIT_KNIGHT"
const MODE_EDIT_SQUIRE = "EDIT_SQUIRE"

export(NodePath) onready var bottom_left = get_node(bottom_left)

export(NodePath) onready var pressed = get_node(pressed)
export(NodePath) onready var picked = get_node(picked)
export(NodePath) onready var tutor_mode = get_node(tutor_mode)
export(NodePath) onready var deck_label = get_node(deck_label)

export(NodePath) onready var deck_btn_0 = get_node(deck_btn_0)
export(NodePath) onready var deck_btn_1 = get_node(deck_btn_1)
export(NodePath) onready var deck_btn_2 = get_node(deck_btn_2)
export(NodePath) onready var deck_btn_3 = get_node(deck_btn_3)
export(NodePath) onready var deck_btn_4 = get_node(deck_btn_4)

export(NodePath) onready var knights_control = get_node(knights_control)
export(NodePath) onready var knight_left = get_node(knight_left)
export(NodePath) onready var knight_center = get_node(knight_center)
export(NodePath) onready var knight_right = get_node(knight_right)

export(NodePath) onready var squires_control = get_node(squires_control)
export(NodePath) onready var squire_0 = get_node(squire_0)
export(NodePath) onready var squire_1 = get_node(squire_1)
export(NodePath) onready var squire_2 = get_node(squire_2)
export(NodePath) onready var squire_3 = get_node(squire_3)
export(NodePath) onready var squire_4 = get_node(squire_4)
export(NodePath) onready var squire_5 = get_node(squire_5)

export(NodePath) onready var filter_knight = get_node(filter_knight)
export(NodePath) onready var filter_squire = get_node(filter_squire)

export(NodePath) onready var container_lists = get_node(container_lists)
export(NodePath) onready var container_founds = get_node(container_founds)
export(NodePath) onready var container_notfounds = get_node(container_notfounds)

export(NodePath) onready var resource_preloader = get_node(resource_preloader)

var pressed_card
var picked_card

var filter = stat.SquireCard

func _ready():
	scroll_max_y = get_vertical_scrollable_control().rect_position.y
	bottom_left.connect("item_rect_changed", self, "calc_scroll_threshold")
	filter_knight.connect("button_up", self, "change_filter", [stat.KnightCard])
	filter_squire.connect("button_up", self, "change_filter", [stat.SquireCard])
	for i in range(user.DECK_COUNT):
		var btn = get("deck_btn_%d" % i)
		btn.connect("button_up", self, "button_up_deck_num", [btn])
	for k in user.KNIGHT_SIDES:
		var btn = get("knight_%s" % k)
		btn.connect("button_up", self, "button_up_deck_item", [btn])
	for i in range(user.SQUIRE_COUNT):
		var btn = get("squire_%d" % i)
		btn.connect("button_up", self, "button_up_deck_item", [btn])
	tutor_mode.connect("button_up", self, "go_to_tutor_mode")

func calc_scroll_threshold():
	var page_height = self.rect_size.y
	var scrollable_height = bottom_left.rect_global_position.y - scrollable.rect_global_position.y
	scroll_min_y = page_height - scrollable_height - lobby.hud.bot.rect_size.y

func invalidate():
	var cur_mode = current_mode()
	var selected = user.DeckSelected
	deck_label.text = "%d" % (selected + 1)
	get("deck_btn_%d" % selected).pressed = true

	var not_found_cards = stat.cards.keys()
	var found_cards = user.Cards.keys()
	var deck = user.Decks[selected]
	for i in range(user.KNIGHT_SIDES.size()):
		var name = deck.Knights[i]
		not_found_cards.erase(name)
		found_cards.erase(name)
		var btn = get("knight_%s" % user.KNIGHT_SIDES[i])
		btn.invalidate(name, cur_mode == MODE_EDIT_SQUIRE)
	for i in range(user.SQUIRE_COUNT):
		var name = deck.Troops[i]
		not_found_cards.erase(name)
		found_cards.erase(name)
		var btn = get("squire_%d" % i)
		btn.invalidate(name, cur_mode == MODE_EDIT_KNIGHT)
	for child in container_founds.get_children():
		child.queue_free()
	for i in range(found_cards.size()):
		var name = found_cards[i]
		not_found_cards.erase(name)
		if filter != stat.cards[name].Type:
			continue
		var item = resource_preloader.get_resource("item").instance()
		item.page_card = get_path()
		container_founds.add_child(item)
		item.invalidate(name)
	for child in container_notfounds.get_children():
		child.queue_free()
	for i in range(not_found_cards.size()):
		var name = not_found_cards[i]
		if filter != stat.cards[name].Type:
			continue
		var item = resource_preloader.get_resource("item").instance()
		item.page_card = get_path()
		container_notfounds.add_child(item)
		item.invalidate(name)
	pressed.invalidate(pressed_card)
	picked.invalidate(picked_card)

	var is_edit = cur_mode in [MODE_EDIT_KNIGHT, MODE_EDIT_SQUIRE]
	if is_edit:
		get_vertical_scrollable_control().rect_position.y = scroll_max_y
	pressed.visible = pressed_card != null and not is_edit
	picked.visible = is_edit
	container_lists.visible = not is_edit
	knights_control.visible = not cur_mode == MODE_EDIT_SQUIRE
	squires_control.visible = not cur_mode == MODE_EDIT_KNIGHT

func current_mode():
	if not stat.cards.has(picked_card):
		return MODE_NORMAL
	var type = stat.units[stat.cards[picked_card].Unit].type
	if type == stat.Knight:
		return MODE_EDIT_KNIGHT
	elif type == stat.Squire:
		return MODE_EDIT_SQUIRE
	return null

func button_up_deck_num(btn):
	if current_mode() != MODE_NORMAL:
		yield(get_tree(), "idle_frame")
		get("deck_btn_%d" % user.DeckSelected).pressed = true
		return
	var pressed_num = int(btn.name[-1])
	var request = lobby.http_manager.new_request(HTTPClient.METHOD_POST, "/edit/deck/select", {"num":pressed_num})
	var response = yield(request, "response")
	if not response[0]:
		lobby.http_manager.handle_error(response[1].ErrMessage)
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
	for side in user.KNIGHT_SIDES:
		var knight_btn = get("knight_%s" % side)
		params.deck.Knights.append(picked_card if knight_btn.name_ == btn.name_ else knight_btn.name_)
	for i in range(user.SQUIRE_COUNT):
		var troop_btn = get("squire_%d" % i)
		params.deck.Troops.append(picked_card if troop_btn.name_ == btn.name_ else troop_btn.name_)
	var request = lobby.http_manager.new_request(HTTPClient.METHOD_POST, "/edit/deck/set", params)
	var response = yield(request, "response")
	if not response[0]:
		lobby.http_manager.handle_error(response[1].ErrMessage)
		return
	picked_card = null
	pressed_card = null
	user.Decks[params.num] = params.deck
	lobby.invalidate()

func set_pressed_card(btn):
	if current_mode() in [MODE_EDIT_KNIGHT, MODE_EDIT_SQUIRE]:
		return
	if pressed_card == btn.name_:
		pressed_card = null
		return
	pressed_card = btn.name_
	pressed.rect_global_position = btn.get_node("Position2D").global_position
	if user.CardInDeck(pressed_card):
		change_filter(stat.cards[pressed_card].Type)
	invalidate()

func set_picked_card(btn):
	picked_card = pressed_card
	invalidate()

func change_filter(filter):
	if self.filter == filter:
		return
	self.filter = filter
	# swap modulate color
	var temp_color = filter_knight.modulate
	filter_knight.modulate = filter_squire.modulate
	filter_squire.modulate = temp_color
	invalidate()

func go_to_tutor_mode():
	var params = config.GAME.duplicate(true)
	for player in params.Players:
		if player.Team == "Red":
			continue
		var k = player.Knights
		k.clear()
		for side in user.KNIGHT_SIDES:
			var knight_btn = get("knight_%s" % side)
			k.append({"Name":knight_btn.name_, "Level":0})
		var d = player.Deck
		d.clear()
		for i in range(user.SQUIRE_COUNT):
			var troop_btn = get("squire_%d" % i)
			d.append({"Name":troop_btn.name_, "Level":0})
	loading_screen.goto_scene("res://game/offline/tutor/tutor.tscn", {"cfg": params})
