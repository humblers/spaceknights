extends BaseButton

export(NodePath) onready var base = get_node(base)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)

var card

func Invalidate(card):
	self.card = card
	self.visible = card != null
	if card == null:
		return
	icon.texture = loading_screen.LoadResource("res://image/icon/%s.png" % card.Name)
	frame.texture = loading_screen.LoadResource("res://atlas/lobby/contents.sprites/card/%s_%s_frame.tres" % [card.Type.replace("Card", "").to_lower(), card.Rarity.to_lower()])