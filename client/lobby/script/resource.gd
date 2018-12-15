extends Node

export(NodePath) onready var scripts = get_node(scripts)
export(NodePath) onready var card_icon = get_node(card_icon)
export(NodePath) onready var card_frame = get_node(card_frame)

func get_card_icon(card):
	return card_icon.get_resource(card)

func get_card_frame(type, rarity):
	var t = "squire"
	if type == data.KnightCard:
		t = "knight"
	return card_frame.get_resource("%s_%s_frame" % [t, rarity.to_lower()])
