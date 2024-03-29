extends "res://lobby/page/scroller.gd"

const MODE_EDIT_KNIGHT = "EDIT_KNIGHT"
const MODE_EDIT_SQUIRE = "EDIT_SQUIRE"

export(NodePath) onready var bottom_left = get_node(bottom_left)

export(NodePath) onready var pressed = get_node(pressed)
export(NodePath) onready var picked = get_node(picked)
export(NodePath) onready var tutor_mode = get_node(tutor_mode)

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

var filter = data.SquireCard

func _ready():
	event.connect("InvalidatePageCard", self, "invalidate")
	event.connect("PageCardPickedCardItem", self, "set_picked_card")
	scroll_max_y = scrollable.rect_position.y
	calc_scroll_threshold()
	bottom_left.connect("item_rect_changed", self, "calc_scroll_threshold")
	filter_knight.connect("button_up", self, "change_filter", [data.KnightCard])
	filter_squire.connect("button_up", self, "change_filter", [data.SquireCard])
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
	var page_height = $PageMain/BottomOverContainer.rect_position.y
	var scrollable_height = bottom_left.rect_global_position.y - scrollable.rect_global_position.y
	scroll_min_y = page_height - scrollable_height
	
func invalidate():
	var cur_mode = current_mode()
	var selected = user.DeckSelected
	get("deck_btn_%d" % selected).pressed = true

	var not_found_cards = data.cards.keys()
	var found_cards = user.Cards.keys()
	var i = 0
	for c in user.DeckSlots[selected]:
		var card = data.NewCard(c)
		card.Level = user.Cards[card.Name].Level
		card.Holding = user.Cards[card.Name].Holding
		not_found_cards.erase(card.Name)
		found_cards.erase(card.Name)
		match card.Type:
			data.KnightCard:
				get("knight_%s" % card.Side.to_lower()).Invalidate(card)
			data.SquireCard:
				get("squire_%d" % i).Invalidate(card)
				i += 1
	for child in container_founds.get_children():
		child.queue_free()
	for i in range(found_cards.size()):
		var name = found_cards[i]
		not_found_cards.erase(name)
		if filter != data.cards[name].Type:
			continue
		var item = resource_preloader.get_resource("item").instance()
		item.page_card = get_path()
		container_founds.add_child(item)
		item.Invalidate(data.NewCard(user.Cards[name]))
	for child in container_notfounds.get_children():
		child.queue_free()
	for i in range(not_found_cards.size()):
		var name = not_found_cards[i]
		if filter != data.cards[name].Type:
			continue
		var item = resource_preloader.get_resource("item_not_found").instance()
		container_notfounds.add_child(item)
		item.Invalidate(data.NewCard({"Name": name, "Level": -1}))
	pressed.Invalidate(pressed_card)
	picked.Invalidate(picked_card)

	var is_edit = cur_mode in [MODE_EDIT_KNIGHT, MODE_EDIT_SQUIRE]
	if is_edit:
		scrollable.rect_position.y = scroll_max_y
	pressed.visible = pressed_card != null and not is_edit
	picked.visible = is_edit
	container_lists.visible = not is_edit
	knights_control.visible = not cur_mode == MODE_EDIT_SQUIRE
	squires_control.visible = not cur_mode == MODE_EDIT_KNIGHT

func current_mode():
	if picked_card == null:
		return MODE_NORMAL
	var type = data.units[picked_card.Unit].type
	if type == data.Knight:
		return MODE_EDIT_KNIGHT
	elif type == data.Squire:
		return MODE_EDIT_SQUIRE
	return null

func button_up_deck_num(btn):
	var pressed_num = int(btn.name[-1])
	var request = lobby_request.New("/edit/deck/select", {"num":pressed_num})
	var response = yield(request, "Completed")
	if not response[0]:
		event.emit_signal("RequestPopup", self, [response[1].ErrMessage])
		return
	user.DeckSelected = pressed_num
	invalidate()
	event.emit_signal("InvalidatePageBattle")

func button_up_deck_item(btn):
	if current_mode() == MODE_NORMAL:
		return

	var params = {
		"num": user.DeckSelected,
		"deck" : [],
	}
	for i in range(user.SQUIRE_COUNT):
		var squire_btn = get("squire_%d" % i)
		params.deck.append(picked_card if squire_btn == btn else squire_btn.card)
	for side in [data.Center, data.Left, data.Right]:
		var knight_btn = get("knight_%s" % side.to_lower())
		var c = picked_card if btn == knight_btn else knight_btn.card
		c = c.duplicate(true)
		c.Side = side
		params.deck.append(c)
	var request = lobby_request.New("/edit/deck/set", params)

	var origin = picked.rect_global_position
	tween.interpolate_property(
			picked,
			"rect_global_position",
			picked.rect_global_position,
			btn.rect_global_position,
			0.2, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	tween.interpolate_property(
			picked,
			"rect_scale",
			picked.rect_scale,
			Vector2(1.5, 1.5),
			0.2, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	tween.start()

	var response = yield(request, "Completed")
	if tween.is_active():
		yield(tween, "tween_completed")
	picked.animation_player.play("changed")
	yield(picked.animation_player, "animation_finished")

	if not response[0]:
		event.emit_signal("RequestMessageModal", self, response[1].ErrMessage)
		return
	var picked_type = picked_card.Type
	picked_card = null
	pressed_card = null
	user.DeckSlots[params.num] = params.deck
	picked.rect_global_position = origin
	invalidate()
	event.emit_signal("InvalidatePageBattle")
	if picked_type == data.SquireCard:
		scrollable.rect_position.y = -knights_control.rect_size.y

func set_pressed_card(card, position = Vector2(0, 0)):
	if current_mode() in [MODE_EDIT_KNIGHT, MODE_EDIT_SQUIRE]:
		return
	if card == null or card == pressed_card:
		pressed_card = null
		invalidate()
		return
	pressed_card = card
	pressed.rect_global_position = position
	change_filter(pressed_card.Type)

func set_picked_card(card):
	picked_card = card
	invalidate()

func change_filter(filter):
	if self.filter != filter:
		# swap modulate color
		var temp_color = filter_knight.modulate
		filter_knight.modulate = filter_squire.modulate
		filter_squire.modulate = temp_color
	self.filter = filter
	if pressed_card != null and \
			not user.CardInDeck(pressed_card.Name) and \
			filter != pressed_card.Type:
		pressed_card = null
	invalidate()

func go_to_tutor_mode():
	var params = config.GAME.duplicate(true)
	var non_preload_paths = []
	for player in params.Players:
		if player.Team == "Red":
			continue
		var d = player.Deck
		d.clear()
		for side in user.KNIGHT_SIDES:
			var knight_btn = get("knight_%s" % side)
			non_preload_paths += loading_screen.GetReqResourcePathsInGame(knight_btn.card)
			d.append({"Name":knight_btn.card.Name, "Level":knight_btn.card.Level, "Side": side.capitalize()})
		for i in range(user.SQUIRE_COUNT):
			var squire_btn = get("squire_%d" % i)
			non_preload_paths += loading_screen.GetReqResourcePathsInGame(squire_btn.card)
			d.append({"Name":squire_btn.card.Name, "Level":squire_btn.card.Level})
	loading_screen.GoToScene("res://game/offline/tutor/tutor.tscn", non_preload_paths, {"cfg": params})
