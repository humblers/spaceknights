extends BaseButton

export(NodePath) onready var page_card = get_node(page_card)
export(NodePath) onready var base = get_node(base)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)

var card

func Invalidate(card):
	self.card = card
	self.visible = card != null
	if card == null:
		return
	icon.texture = page_card.lobby.resource_manager.get_card_icon(card.Name)
	frame.texture = page_card.lobby.resource_manager.get_card_frame(card.Type, card.Rarity)