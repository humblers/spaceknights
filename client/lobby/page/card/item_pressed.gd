extends BaseButton

export(NodePath) onready var page_card = get_node(page_card)
export(NodePath) onready var container = get_node(container)
export(NodePath) onready var base = get_node(base)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var cost = get_node(cost)
export(NodePath) onready var use = get_node(use)

var name_

func _ready():
	self.connect("button_up", page_card, "set_pressed_card", [self])
	use.connect("button_up", page_card, "set_picked_card", [self])

func invalidate(name):
	self.name_ = name
	self.visible = name != null
	if name == null:
		return
	use.visible = not user.CardInDeck(name)
	container.rect_size.y = 0 # force downsizing
	icon.texture = page_card.lobby.resource_manager.get_card_icon(name_)
	var data = stat.cards[name_]
	frame.texture = page_card.lobby.resource_manager.get_card_frame(data.Type, data.Rarity)
	cost.text = "%d" % (data.Cost / 1000)