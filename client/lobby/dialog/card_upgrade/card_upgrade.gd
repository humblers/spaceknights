extends Control

const STAT_ORDER = [
	"hp", "shield", 
	"attackdamage", "destroydamage", "damagepersecond",
	"chargedattackdamage", "powerattackdamage", "damage", 
	"hpratio", "attackdamageratio", "attackrangeratio", 
	"slowduration",
	"leader", "wing"
]

export(NodePath) onready var card_name_label = get_node(card_name_label)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var stat_container = get_node(stat_container)
export(NodePath) onready var button = get_node(button)
export(NodePath) onready var holding_label = get_node(holding_label)
export(NodePath) onready var holding_progress = get_node(holding_progress)
export(NodePath) onready var decrease_animation_player = get_node(decrease_animation_player)

export(NodePath) onready var animation_player = get_node(animation_player)

func _ready():
	button.connect("button_up", self, "buttonUp")
	var anim_name = "upgrade"
	decrease_animation_player.rename_animation(anim_name, "%s-ref" % [anim_name])

func PopUp(card):
	icon.texture = loading_screen.LoadResource("res://image/icon/%s.png" % card.Name)
	frame.texture = loading_screen.LoadResource("res://atlas/lobby/popup.sprites/card/%s_%s_frame.tres" % [card.Type.replace("Card", "").to_lower(), card.Rarity.to_lower()])
	card_name_label.SetText("ID_%s" % card.Name.to_upper())
	level_label.text = "%02d" % (card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity])
	makeUpgradeBar(card)
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
		var icon_texture = loading_screen.GetStatIcon("popup", key)
		item_nodes[idx].Invalidate(icon_texture, key_text, value_cur, value_increased)
		idx += 1
	for i in range(len(item_nodes)):
		item_nodes[i].visible = i < idx
	animation_player.play("card_upgrade")

func makeUpgradeBar(card):
	var decrease_anim_name
	self.visible = card != null
	if card == null:
		decrease_anim_name = null
		return
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	var pre_card_cost = data.Upgrade.CardCostNextLevel(card.Level-1)
	var holding_value = pre_card_cost
	holding_label.text = "%d/%d" % [pre_card_cost, pre_card_cost]
	holding_progress.max_value = pre_card_cost
	holding_progress.value = pre_card_cost
	decrease_anim_name = "upgrade"
	var anim = decrease_animation_player.get_animation("%s-ref" % [decrease_anim_name]).duplicate()
	decrease_animation_player.add_animation(decrease_anim_name, anim)
	var text_track_idx = anim.find_track("Front/HoldingBar/Label:text")
	var value_track_idx = anim.find_track("Front/HoldingBar/UpgradeProgress:value")
	var level_track_idx = anim.find_track("Front/Base/Control/Lv:text")
	# this is strict restriction of these animations
	var key_num = anim.track_get_key_count(text_track_idx)
	assert(key_num == anim.track_get_key_count(value_track_idx))
	for i in key_num:
		if pre_card_cost > key_num:
			holding_value = round(pre_card_cost - pre_card_cost * i / (key_num - 1))
		else:
			holding_value = max(0, holding_value - 1)
		anim.track_set_key_value(text_track_idx, i, "%d/%d" % [holding_value, pre_card_cost])
		anim.track_set_key_value(value_track_idx, i, holding_value)
	anim.track_set_key_value(level_track_idx, 0, "%02d" % (int(level_label.text)))
	anim.track_set_key_value(level_track_idx, 1, "%02d" % (int(level_label.text) + 1))

func buttonUp():
	if animation_player.is_playing() and\
			animation_player.current_animation == "card_upgrade":
		return
	animation_player.play("close")

func keyText(key, unit):
	match key:
		"area":
			return "ID_AREA"
		"attackdamage":
			var t = "ID_DAMAGE"
			if unit.has("damageradius"):
				t = "ID_AREADAMAGE"
			return t
		"attackinterval":
			return "ID_ATTACKSPEED"
		"attackrange":
			return "ID_RANGE"
		"castduration":
			return "ID_CASTDURATION"
		"chargedattackdamage", "powerattackdamage", "absorbdamage":
			return "ID_SKILLDAMAGE"		
		"count":
			return "ID_COUNT"
		"damage":
			return "ID_AREADAMAGE"
		"damageduration":
			return "ID_DAMAGEDURATION"
		"damagepersecond":
			var t = "ID_DPS"
			if unit.has("damageradius"):
				t = "ID_AREADPS"
			return t
		"damagetype":
			return "ID_ATTACKTYPE"
		"decaydamage":
			return "ID_LIFETIME"
		"destroydamage":
			return "ID_DEATHDAMAGE"
		"freezeduration":
			return "ID_FREEZEDURATION"
		"hp":
			return "ID_HP"
		"leader", "wing":
			return "ID_%s_SKILL" % key.to_upper()
		"radius":
			return "ID_RADIUS"
		"shield":
			return "ID_BARRIER"
		"spawninterval":
			return "ID_SPAWNSPEED"
		"speed":
			return "ID_SPEED"
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
				 return ["ID_%s" % unit.skill[key].name.to_upper(), "+1"]
	return null
