extends "res://lobby/page/page.gd"

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

export(NodePath) onready var knight_left = get_node(knight_left)
export(NodePath) onready var knight_center = get_node(knight_center)
export(NodePath) onready var knight_right = get_node(knight_right)

export(NodePath) onready var troops_0 = get_node(troops_0)
export(NodePath) onready var troops_1 = get_node(troops_1)
export(NodePath) onready var troops_2 = get_node(troops_2)
export(NodePath) onready var troops_3 = get_node(troops_3)
export(NodePath) onready var troops_4 = get_node(troops_4)
export(NodePath) onready var troops_5 = get_node(troops_5)

export(NodePath) onready var filter_knight = get_node(filter_knight)
export(NodePath) onready var filter_squire = get_node(filter_squire)

export(NodePath) onready var container_lists = get_node(container_lists)
export(NodePath) onready var container_founds = get_node(container_founds)
export(NodePath) onready var container_notfounds = get_node(container_notfounds)

var lobby
var pressed_card
var picked_card

var filter = "Troop"

func _ready():
	scroll_max_y = get_vertical_scrollable_control().rect_position.y
	bottom_left.connect("item_rect_changed", self, "calc_scroll_threshold")
	filter_knight.connect("button_up", self, "change_filter", ["Knight"])
	filter_squire.connect("button_up", self, "change_filter", ["Troop"])
	for i in range(user.DECK_COUNT):
		var btn = get("deck_btn_%d" % i)
		btn.connect("button_up", self, "button_up_deck_num", [btn])
	for k in user.KNIGHT_SIDES:
		var btn = get("knight_%s" % k)
		btn.connect("button_up", self, "button_up_deck_item", [btn])
	for i in range(user.SQUIRE_COUNT):
		var btn = get("troops_%d" % i)
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
		btn.invalidate(name, self, cur_mode == MODE_EDIT_TROOP)
	for i in range(user.SQUIRE_COUNT):
		var name = deck.Troops[i]
		not_found_cards.erase(name)
		found_cards.erase(name)
		var btn = get("troops_%d" % i)
		btn.invalidate(name, self, cur_mode == MODE_EDIT_KNIGHT)
	for child in container_founds.get_children():
		child.queue_free()
	for i in range(found_cards.size()):
		var name = found_cards[i]
		not_found_cards.erase(name)
		if filter != stat.units[stat.cards[name].Unit]["type"]:
			continue
		var item = $ResourcePreloader.get_resource("item").instance()
		container_founds.add_child(item)
		item.invalidate(name, self)
	for child in container_notfounds.get_children():
		child.queue_free()
	pressed.invalidate(pressed_card, self)
	picked.invalidate(picked_card, self)

	var is_edit = cur_mode in [MODE_EDIT_KNIGHT, MODE_EDIT_TROOP]
	if is_edit:
		get_vertical_scrollable_control().rect_position.y = scroll_max_y
	pressed.visible = pressed_card != null and not is_edit
	picked.visible = is_edit
	container_lists.visible = not is_edit

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
	for side in user.KNIGHT_SIDES:
		var knight_btn = get("knight_%s" % side)
		params.deck.Knights.append(picked_card if knight_btn.name_ == btn.name_ else knight_btn.name_)
	for i in range(user.SQUIRE_COUNT):
		var troop_btn = get("troops_%d" % i)
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
		change_filter(stat.units[stat.cards[pressed_card].Unit]["type"])
	invalidate()

func set_picked_card(btn):
	picked_card = pressed_card
	invalidate()

func change_filter(filter):
	self.filter = filter
	var pressed_color = Color(1, 1, 1, 1)
	var non_pressed_color = Color(1, 1, 1, 0.392157)
	filter_knight.modulate = pressed_color if filter == "Knight" else non_pressed_color
	filter_squire.modulate = non_pressed_color if filter == "Knight" else pressed_color
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
			var troop_btn = get("troop_%d" % i)
			d.append({"Name":troop_btn.name_, "Level":0})
	loading_screen.goto_scene("res://game/offline/tutor/tutor.tscn", {"cfg": params})