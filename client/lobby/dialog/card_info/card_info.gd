extends Control

const MAX_STAT_COUNT = 10

export(Color) var rarity_panel_common
export(Color) var rarity_panel_rare
export(Color) var rarity_panel_epic
export(Color) var rarity_panel_legendary

export(NodePath) onready var hud = get_node(hud)

export(NodePath) onready var main_popup = get_node(main_popup)
export(NodePath) onready var sub_popup = get_node(sub_popup)

export(NodePath) onready var card_name_label = get_node(card_name_label)
export(NodePath) onready var rarity_label = get_node(rarity_label)
export(NodePath) onready var cost_label = get_node(cost_label)
export(NodePath) onready var rarity_panel = get_node(rarity_panel)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)

export(NodePath) onready var icon_resource = get_node(icon_resource)

var card
var unit

func PopUp(card):
	self.card = card
	self.unit = data.units[card.Unit]
	invalidate()
	main_popup.Invalidate(card, unit)
	self.visible = true

func Hide():
	self.visible = false

func PopUpSub(pressed):
	sub_popup.Invalidate(card, pressed)

func invalidate():
	rarity_panel.modulate = get("rarity_panel_%s" % card.Rarity.to_lower())
	icon.texture = hud.lobby.resource_manager.get_card_icon(card.Name)
	frame.texture = hud.lobby.resource_manager.get_card_frame(card.Type, card.Rarity)
	static_func.set_text(card_name_label, card.Name)
	static_func.set_text(rarity_label, card.Rarity)
	static_func.set_text(cost_label, "%d" % (card.Cost / 1000))

func IconTexture(key):
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

func FormatStepToSecond(steps):
	var in_secs = float(steps) / data.StepPerSec
	return "%.*fs" % [1 if decimals(in_secs) > 0 else 0, in_secs]

func FormatPixelToTile(pixels):
	var in_tiles = float(pixels) / data.TileSizeInPixel
	return "%.*f" % [ 1 if decimals(in_tiles) > 0 else 0, in_tiles]

func FormatSpeed(speed):
	if speed > 150:
		return "Very Fast"
	if speed > 100:
		return "Fast"
	if speed > 75:
		return "Medium"
	if speed > 0:
		return "Slow"
	return null

func FormatAttackType(target_types, attack_type, damage_type):
	var types = PoolStringArray()
	if len(target_types) > 0 and not target_types.has(data.Squire):
		types.append("Siege")
	if attack_type == data.Bombing:
		types.append(data.Bombing)
	if damage_type == data.AntiShield:
		types.append("AB Attack")
	if len(types) == 0:
		return null
	if len(types) > 2:
		types.resize(2)
	return types.join(" & ")