extends PopupPanel

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
	self.connect("popup_hide", info_root, "Hide")

func Invalidate(card, unit):
	var item_nodes = stat_container.get_children()
	var pointer = 0
	for key in STAT_ORDER:
		var value_text = valueText(key, card, unit)
		if value_text == null:
			continue
		var key_text = keyText(key, unit)
		var icon_texture = info_root.IconTexture(key)
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
	self.popup()

func keyText(key, unit):
	match key:
		"attackdamage":
			var t = "Damage"
			if unit.has("damageradius"):
				t = "Area %s" % t
			return t
		"chargedattackdamage", "powerattackdamage", "absorbdamage":
			return "Skill Damage"
		"damagepersecond":
			var t = "Damage Per Second"
			if unit.has("damageradius"):
				t = "Area %s" % t
			return t
		"destroydamage":
			return "Death Damage"
		"hp":
			return "Hit Points"
		"shield":
			return "Barrier Points"
		"attackinterval":
			return "Attack Speed"
		"damagetype":
			return "Attack Type"
		"attackrange":
			return "Range"
		"leader", "wing":
			return "%s Skill" % key.capitalize()
		"freezeduration":
			return "Freeze Duration"
		"spawninterval":
			return "Spawn Speed"
		"spawncount":
			return "%s Count" % "spawn unit name"
	return key.capitalize()

func valueText(key, card, unit):
	match key:
		"attackdamage", "destroydamage", \
		"chargedattackdamage", "powerattackdamage", \
		"hp", "shield":
			if unit.has(key):
				return "%d" % unit[key][card.Level]
		"absorbdamage":
			if unit.has(key):
				return "%d" % unit[key]
		"attackinterval":
			return info_root.FormatStepToSecond(unit[key])
		"damagepersecond":
			if unit.has("attackdamage") and unit.has("attackinterval"):
				return "%d" % [ceil(float(unit["attackdamage"][card.Level]) / unit["attackinterval"] * data.StepPerSec)]
		"damagetype":
			var target_types = unit.get("targettypes", {})
			var atk_type = unit.get("attacktype", "")
			var dmg_type = unit.get("damagetype", "")
			return info_root.FormatAttackType(target_types, atk_type, dmg_type)
		"attackrange":
			var attack_type = unit.get("attacktype", "")
			if attack_type == data.Melee:
				return attack_type
			return info_root.FormatPixelToTile(unit[key])
		"speed":
			return info_root.FormatSpeed(unit.get(key, 0))
		"leader", "wing":
			if card.Type == data.KnightCard:
				 return unit.skill[key].name.capitalize()
		"count":
			if card.Count > 1:
				return "%d" % card.Count
	if unit.has(key):
		return String(unit[key]).capitalize()
	return null
