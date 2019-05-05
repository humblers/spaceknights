extends MarginContainer

export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var cost_label = get_node(cost_label)
export(NodePath) onready var level_label = get_node(level_label)

func Invalidate(card):
	icon.texture = loading_screen.LoadResource("res://image/icon/%s.png" % card.Name)
	frame.texture = loading_screen.LoadResource("res://atlas/lobby/contents.sprites/card/%s_%s_frame.tres" % [card.Type.replace("Card", "").to_lower(), card.Rarity.to_lower()])
	cost_label.text = "%d" % (card.Cost / 1000)
	level_label.text = "%02d" % (card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity] + 1)
	level_label.modulate = Color(1, 1, 1, 1)