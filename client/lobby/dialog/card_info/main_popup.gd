extends TextureButton

const STAT_ORDER = [
	"attackdamage",
	"chargedattackdamage", "powerattackdamage", "absorbdamage",
	"destroydamage",
	"damagepersecond",
	"hp", "shield",
	"attackinterval",
	"damagetype",
	"speed",
	"attackrange",
	"leader", "wing",
	"count",
]

export(NodePath) onready var info_root = get_node(info_root)
export(NodePath) onready var stat_container = get_node(stat_container)

func _ready():
	self.connect("button_up", info_root, "hide")

func Invalidate(card, unit):
	var item_nodes = stat_container.get_children()
	var pointer = 0
	for key in STAT_ORDER:
		var value_text = valueText(key, card, unit)
		if value_text == null:
			continue
		var key_text = keyText(key, unit)
		var icon_key = key
		if unit.has("damageradius"):
			match key:
				"attackdamage":
					icon_key = "areadamage"
				"damagepersecond":
					icon_key = "areadps"
		var icon_texture = loading_screen.GetStatIcon("contents", icon_key)
		var sub_info = unit.get("skill", {}).get(key, null)
		if sub_info != null:
			sub_info = sub_info.duplicate(true)
			sub_info["type"] = key
		item_nodes[pointer].Invalidate(icon_texture, key_text, value_text, sub_info)
		pointer += 1
		if pointer >= info_root.MAX_STAT_COUNT:
			break
	for i in range(info_root.MAX_STAT_COUNT):
		item_nodes[i].visible = i < pointer
	self.visible = true

func keyText(key, unit):
	match key:
		"attackdamage":
			var t = "ID_DAMAGE"
			if unit.has("damageradius"):
				t = "ID_AREADAMAGE"
			return t
		"attackinterval":
			return "ID_ATTACKSPEED"
		"attackrange":
			return "ID_RANGE"
		"chargedattackdamage", "powerattackdamage", "absorbdamage":
			return "ID_SKILLDAMAGE"
		"count":
			return "ID_COUNT"
		"damagepersecond":
			var t = "ID_DPS"
			if unit.has("damageradius"):
				t = "ID_AREADPS"
			return t
		"damagetype":
			return "ID_ATTACKTYPE"
		"destroydamage":
			return "ID_DEATHDAMAGE"
		"freezeduration":
			return "ID_FREEZEDURATION"
		"hp":
			return "ID_HP"
		"leader", "wing":
			return "ID_%s_SKILL" % key.to_upper()
		"shield":
			return "ID_BARRIER"
		"spawninterval":
			return "ID_SPAWNSPEED"
		"speed":
			return "ID_SPEED"
		_:
			print("key text format failed")

func valueText(key, card, unit):
	match key:
		"attackdamage", "destroydamage", \
		"chargedattackdamage", "powerattackdamage", \
		"hp", "shield":
			if unit.has(key):
				var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
				return "%d" % unit[key][lv]
		"absorbdamage":
			if unit.has(key):
				return "%d" % unit[key]
		"attackinterval":
			if unit.has(key):
				return static_func.FormatStepToSecond(unit[key])
		"damagepersecond":
			if unit.has("attackdamage") and unit.has("attackinterval"):
				var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
				return "%d" % [ceil(float(unit["attackdamage"][lv]) / unit["attackinterval"] * data.StepPerSec)]
		"damagetype":
			var target_types = unit.get("targettypes", {})
			var atk_type = unit.get("attacktype", "")
			var dmg_type = unit.get("damagetype", "")
			return static_func.FormatAttackType(target_types, atk_type, dmg_type)
		"attackrange":
			if data.DamageTypeIs(unit.get("damagetype", 0), data.Melee):
				return "ID_MELEE"
			return static_func.FormatPixelToTile(unit[key])
		"speed":
			return static_func.FormatSpeed(unit.get(key, 0))
		"leader", "wing":
			if card.Type == data.KnightCard:
				 return "ID_%s" % unit.skill[key].name.to_upper()
		"count":
			if card.Count > 1:
				return "%d" % card.Count
	if unit.has(key):
		return String(unit[key]).capitalize()
	return null
