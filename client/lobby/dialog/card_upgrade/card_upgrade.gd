extends Control

const STAT_ORDER = [
	"hp", "shield", 
	"attackdamage", "destroydamage", "damagepersecond",
	"chargedattackdamage", "powerattackdamage", "damage", 
	"hpratio", "attackdamageratio", "attackrangeratio", 
	"slowduration",
	"leader", "wing"
]

export(Color) var increased

export(NodePath) onready var hud = get_node(hud)

export(NodePath) onready var card_name_label = get_node(card_name_label)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var stat_container = get_node(stat_container)
export(NodePath) onready var button = get_node(button)

export(NodePath) onready var animation_player = get_node(animation_player)

func _ready():
	button.connect("button_up", self, "buttonUp")

func PopUp(card):
	icon.texture = hud.lobby.resource_manager.get_card_icon(card.Name)
	frame.texture = hud.lobby.resource_manager.get_card_frame(card.Type, card.Rarity)
	card_name_label.SetText("ID_%s" % card.Name.to_upper())
	level_label.text = "%02d" % card.Level
	var unit = data.units[card.Unit]
	var item_nodes = stat_container.get_children()
	var idx = 0
	for key in STAT_ORDER:
		var value_texts = valueTexts(key, card, unit)
		if value_texts == null:
			continue
		var value_cur = value_texts[0]
		var value_increased = value_texts[1]
		var key_text = keyText(key, unit)
		var icon_texture = hud.lobby.resource_manager.StatIcon(key)
		item_nodes[idx].Invalidate(icon_texture, key_text, value_cur, value_increased)
		idx += 1
	for i in range(len(item_nodes)):
		item_nodes[i].visible = i < idx
	animation_player.play("card_upgrade")

func increaseLevel():
	level_label.text = "%02d" % (int(level_label.text) + 1)
	level_label.modulate = increased

func buttonUp():
	if animation_player.is_playing():
		if animation_player.current_animation == "card_upgrade":
			animation_player.advance(animation_player.current_animation_length)
		return
	animation_player.play("close")

func keyText(key, unit):
	match key:
		"attackdamage":
			var t = "ID_DAMAGE"
			if unit.has("damageradius"):
				t = "ID_AREADAMAGE"
			return t
		"chargedattackdamage", "powerattackdamage", "absorbdamage":
			return "ID_SKILLDAMAGE"
		"damagepersecond":
			var t = "ID_DPS"
			if unit.has("damageradius"):
				t = "ID_AREADPS"
			return t
		"destroydamage":
			return "ID_DEATHDAMAGE"
		"hp":
			return "ID_HP"
		"shield":
			return "ID_BARRIER"
		"leader", "wing":
			return "ID_%s_SKILL" % key.to_upper()
	return key.capitalize()

func valueTexts(key, card, unit):
	match key:
		"attackdamage", "destroydamage", \
		"chargedattackdamage", "powerattackdamage", \
		"hp", "shield":
			if unit.has(key):
				var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
				var cur = unit[key][lv]
				var before = unit[key][lv-1]
				return ["%d" % cur, "+%d" % (cur - before)]
		"damagepersecond":
			if unit.has("attackdamage") and unit.has("attackinterval"):
				var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
				var cur = ceil(float(unit["attackdamage"][lv]) / unit["attackinterval"] * data.StepPerSec)
				var before = ceil(float(unit["attackdamage"][lv-1]) / unit["attackinterval"] * data.StepPerSec)
				return ["%d" % cur, "+%d" % (cur - before)]
		"leader", "wing":
			if card.Type == data.KnightCard:
				 return ["%s" % unit.skill[key].name.capitalize(), "+1"]
	return null