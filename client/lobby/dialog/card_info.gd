extends Control

const MAX_STAT_COUNT = 10
const STATS_WITH_ORDER = [
	{
		"stat_key":   "attackdamage",
		"label_text": "damage",
		"icon":       "damage"
	},
	{
		"stat_key":   "damage",
		"label_text": "damage",
		"icon":       "damage"
	},
	{
		"stat_key":   "chargedattackdamage",
		"label_text": "skill damage",
		"icon":       "damage"
	},
	{
		"stat_key":   "powerattackdamage",
		"label_text": "skill damage",
		"icon":       "damage"
	},
	{
		"stat_key":   "absorbdamage",
		"label_text": "skill damage",
		"icon":       "damage"
	},
	{
		"stat_key":   "destroydamage",
		"label_text": "death damage",
		"icon":       "damage"
	},
	{
		"stat_key":   "damagepersecond",
		"label_text": "damage per second",
		"icon":       "damagepersecond"
	},
	{
		"stat_key":   "hp",
		"label_text": "hitponints",
		"icon":       "hp"
	},
	{
		"stat_key":   "shield",
		"label_text": "shiedpoints",
		"icon":       "hp"
	},
	{
		"stat_key":   "attackinterval",
		"label_text": "attack speed",
		"icon":       "attackspeed"
	},
	{
		"stat_key":   "damagetype",
		"label_text": "attack type",
		"icon":       "attacktype"
	},
	{
		"stat_key":   "speed",
		"label_text": "speed",
		"icon":       "speed"
	},
	{
		"stat_key":   "attackrange",
		"label_text": "range",
		"icon":       "attackrange"
	},
	{
		"stat_key":   "radius",
		"label_text": "radius",
		"icon":       "radius"
	},
	{
		"stat_key":   "width",
		"label_text": "area",
		"icon":       "radius"
	},
	{
		"stat_key":   "leader",
		"label_text": "leader skill",
		"icon":       "damage"
	},
	{
		"stat_key":   "wing",
		"label_text": "wing skill",
		"icon":       "damage"
	},
	{
		"stat_key":   "freezeduration",
		"label_text": "freeze duration",
		"icon":       "damage"
	},
	{
		"stat_key":   "count",
		"label_text": "count",
		"icon":       "count"
	},
	{
		"stat_key":   "spawninterval",
		"label_text": "spawn speed",
		"icon":       "count"
	},
	{
		"stat_key":   "decaydamage",
		"label_text": "lifetime",
		"icon":       "lifetime"
	},
	{
		"stat_key":   "spawncount",
		"label_text": "count",
		"icon":       "count"
	},
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

func Popup(card):
	self.card = card
	self.unit = stat.units[card.Unit]
	invalidate()
	self.visible = true
	main_popup.popup()

func popup_hide():
	self.visible = false

func PopupSub(pos_node):
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
	for s in STATS_WITH_ORDER:
		var key = s.stat_key
		var value = valueText(key)
		if value == null:
			continue
		var label_text = s.label_text.capitalize()
		var icon_texture = icon_resource.get_resource(s.icon)
		main_stats[pointer].invalidate(icon_texture, label_text, value, unit.get("skill", {}).get(key, null))
		pointer += 1
		if pointer >= MAX_STAT_COUNT:
			break
	for i in range(pointer, MAX_STAT_COUNT):
		main_stats[i].visible = false

func valueText(key):
	match key:
		"leader", "wing":
			if card.Type == stat.KnightCard:
				return unit.skill[key].name
		"count":
			if card.Count > 1:
				return card.Count
		_:
			return unit.get(key, null)
	return null

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