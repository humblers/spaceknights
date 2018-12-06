extends Control

const MAX_STAT_COUNT = 10
const MAIN_STAT_ORDER = [
	"attackdamage", "damage",
	"chargedattackdamage", "powerattackdamage", "powerattackdamage", "absorbdamage",
	"destroydamage",
	"damagepersecond",
	"hp", "shield",
	"attackinterval",
	"damagetype",
	"speed",
	"attackrange",
	"radius", "area",
	"leader", "wing",
	"freezeduration",
	"count",
	"spawninterval",
	"decaydamage",
	"spawncount",
]

export(Color) var rarity_panel_common
export(Color) var rarity_panel_rare
export(Color) var rarity_panel_epic
export(Color) var rarity_panel_legendary

export(NodePath) onready var hud = get_node(hud)

export(NodePath) onready var main_popup = get_node(main_popup)
export(NodePath) onready var sub_popup = get_node(sub_popup)

export(NodePath) onready var card_name_label = get_node(card_name_label)
export(NodePath) onready var rarity_label = get_node(rarity_label)
export(NodePath) onready var rarity_panel = get_node(rarity_panel)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var cost = get_node(cost)

export(NodePath) onready var main_stat_container = get_node(main_stat_container)
export(NodePath) onready var sub_stat_container = get_node(sub_stat_container)
export(NodePath) onready var icon_resource = get_node(icon_resource)

var card
var unit

func _ready():
	main_popup.connect("popup_hide", self, "popup_hide")

func PopUp(card):
	self.card = card
	self.unit = stat.units[card.Unit]
	invalidate()
	self.visible = true
	main_popup.popup()

func popup_hide():
	self.visible = false

func PopUpSub(pos_node):
	sub_popup.rect_global_position = pos_node.global_position
	sub_popup.popup()

func invalidate():
	card_name_label.text = card.Name
	rarity_label.text = card.Rarity
	rarity_panel.modulate = get("rarity_panel_%s" % card.Rarity.to_lower())
	icon.texture = hud.lobby.resource_manager.get_card_icon(card.Name)
	frame.texture = hud.lobby.resource_manager.get_card_frame(card.Type, card.Rarity)
	cost.text = "%d" % (card.Cost / 1000)
	var main_stats = main_stat_container.get_children()
	var pointer = 0
	for key in MAIN_STAT_ORDER:
		var value_text = valueText(key)
		if value_text == null:
			continue
		var label_text = keyText(key)
		var icon_texture = iconTexture(key)
		main_stats[pointer].invalidate(icon_texture, label_text, value_text, unit.get("skill", {}).get(key, null))
		pointer += 1
		if pointer >= MAX_STAT_COUNT:
			break
	for i in range(pointer, MAX_STAT_COUNT):
		main_stats[i].visible = false

func keyText(key):
	var ret_text = key
	match key:
		"damage", "attackdamage", "damagepersecond":
			ret_text = "damage"
			if unit.has("damageradius"):
				ret_text = "area %s" % ret_text
		"chargedattackdamage", "powerattackdamage", "powerattackdamage", "absorbdamage":
			ret_text = "skill damage"
		"destroydamage":
			ret_text = "death damage"
		"hp":
			ret_text = "hit points"
		"shield":
			ret_text = "barrier points"
		"attackinterval":
			ret_text = "attack speed"
		"damagetype":
			ret_text = "attack type"
		"attackrange":
			ret_text = "range"
		"leader", "wing":
			ret_text = "%s skill" % ret_text
		"freezeduration":
			ret_text = "freeze duration"
		"spawninterval":
			ret_text = "spawn speed"
		"decaydamage":
			ret_text = "lifetime"
		"spawncount":
			ret_text = "%s count" % ret_text
	return ret_text.capitalize()

func valueText(key):
	match key:
		"damage", "attackdamage":
			if unit.has(key):
				return unit[key][card.Level]
		
		"leader", "wing":
			if card.Type == stat.KnightCard:
				return unit.skill[key].name
		"count":
			if card.Count > 1:
				return card.Count
	return unit.get(key, null)

func iconTexture(key):
	var texture
	match key:
		"damage", "attackdamage":
			texture = icon_resource.get_resource("damage")
		"damagepersecond":
			texture = icon_resource.get_resource("damagepersecond")
		"attackinterval":
			texture = icon_resource.get_resource("attackspeed")
		"damagetype":
			texture = icon_resource.get_resource("attacktype")
		"decaydamage":
			texture = icon_resource.get_resource("lifetime")
		_:
			texture = icon_resource.get_resource(key)
	if texture == null:
		texture = icon_resource.get_resource("damage")
	return texture

func formatSpeed(speed):
	if speed > 150:
		return "very fast"
	elif speed > 100:
		return "fast"
	elif speed > 75:
		return "medium"
	elif speed > 0:
		return "slow"
	return null