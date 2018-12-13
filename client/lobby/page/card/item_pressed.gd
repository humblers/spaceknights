extends TextureButton

export(NodePath) onready var page_card = get_node(page_card)
export(NodePath) onready var base = get_node(base)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var cost = get_node(cost)
export(NodePath) onready var container = get_node(container)
export(NodePath) onready var main_btn = get_node(main_btn)
export(NodePath) onready var info_btn = get_node(info_btn)
export(NodePath) onready var use_btn = get_node(use_btn)

var name_

func _ready():
	main_btn.connect("button_up", page_card, "set_pressed_card", [self])
	info_btn.connect("button_up", self, "pop_card_info")
	use_btn.connect("button_up", page_card, "set_picked_card", [self])

func invalidate(name):
	self.name_ = name
	self.visible = name != null
	if name == null:
		return
	use_btn.visible = not user.CardInDeck(name)
	container.rect_size.y = 0 # force downsizing
	var d = data.cards[name_]
	icon.texture = page_card.lobby.resource_manager.get_card_icon(name_)
	frame.texture = page_card.lobby.resource_manager.get_card_frame(d.Type, d.Rarity)
	cost.text = "%d" % (d.Cost / 1000)

func pop_card_info():
	var card = user.Cards[name_].duplicate(true)
	card.Name = name_
	page_card.lobby.hud.pop_card_info(data.NewCard(card))
