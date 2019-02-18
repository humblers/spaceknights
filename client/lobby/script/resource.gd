extends Node

export(NodePath) onready var scripts = get_node(scripts)
export(NodePath) onready var card_icon = get_node(card_icon)
export(NodePath) onready var card_frame = get_node(card_frame)
export(NodePath) onready var stat_icon = get_node(stat_icon)

func get_card_icon(card):
	return card_icon.get_resource(card)

func get_card_frame(type, rarity):
	var t = "squire"
	if type == data.KnightCard:
		t = "knight"
	return card_frame.get_resource("%s_%s_frame" % [t, rarity.to_lower()])

func StatIcon(stat_key):
	var texture
	match stat_key:
		"damage", "attackdamage":
			texture = stat_icon.get_resource("damage")
		"damagepersecond":
			texture = stat_icon.get_resource("damagepersecond")
		"attackinterval":
			texture = stat_icon.get_resource("attackspeed")
		"chargedattackdamage", "powerattackdamage", "absorbdamage":
			texture = stat_icon.get_resource("skilldamage")
		"damagetype":
			texture = stat_icon.get_resource("attacktype")
		"decaydamage":
			texture = stat_icon.get_resource("lifetime")
		_:
			texture = stat_icon.get_resource(stat_key)
	return texture