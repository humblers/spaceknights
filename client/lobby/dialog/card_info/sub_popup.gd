extends PopupPanel

const STAT_ORDER = [
	"castduration", "duration", "damageduration",
	"damage", "attackdamage",
	"damagepersecond",
	"hp", "shield",
	"attackinterval",
	"damagetype",
	"speed",
	"attackrange",
	"radius", "area",
	"freezeduration",
	"decaydamage",
	"spawninterval",
	"count", "spawncount",
]

export(NodePath) onready var info_root = get_node(info_root)
export(NodePath) onready var stat_container = get_node(stat_container)
export(NodePath) onready var description_label = get_node(description_label)

export(NodePath) onready var left_point = get_node(left_point)
export(NodePath) onready var right_point = get_node(right_point)

func Invalidate(card, pressed):
	self.rect_global_position = pressed.sub_popup_pos.global_position
	left_point.visible = pressed.is_left
	right_point.visible = not pressed.is_left
	description_label.visible = pressed.sub_info.type == "leader"
	stat_container.visible = pressed.sub_info.type == "wing"
	if pressed.sub_info.type == "leader":
		description_label.text = tr("ID_LEADER_SKILL_%s" % card.Name)
	else:
		var item_nodes = stat_container.get_children()
		var pointer = 0
		for key in STAT_ORDER:
			var value_text = valueText(key, card, pressed.sub_info)
			if value_text == null:
				continue
			var key_text = keyText(key, pressed.sub_info)
			var icon_texture = info_root.hud.lobby.resource_manager.StatIcon(key)
			item_nodes[pointer].Invalidate(icon_texture, key_text, value_text, null)
			pointer += 1
			if pointer >= info_root.MAX_STAT_COUNT:
				break
		for i in range(info_root.MAX_STAT_COUNT):
			item_nodes[i].visible = i < pointer
	self.popup()

func keyText(key, skill):
	match key:
		"castduration":
			return "ID_CASTDURATION"
		"damageduration":
			return "ID_DAMAGEDURATION"
		"damage":
			return "ID_AREADAMAGE"
		"attackdamage":
			var t = "ID_DAMAGE"
			var u = data.units.get(skill.get("unit", ""), {})
			if u.get("damageradius", null) != null:
				t = "ID_AREADAMAGE"
			return t
		"damagepersecond":
			var t = "ID_DPS"
			var u = data.units.get(skill.get("unit", ""), {})
			if u.get("damageradius", null) != null:
				t = "ID_AREADPS"
			return t
		"destroydamage":
			return "ID_DEATHDAMAGE"
		"hp":
			return "ID_HP"
		"shield":
			return "ID_BARRIER"
		"attackinterval":
			return "ID_ATTACKSPEED"
		"damagetype":
			return "ID_ATTACKTYPE"
		"attackrange":
			return "ID_RANGE"
		"freezeduration":
			return "ID_FREEZEDURATION"
		"spawninterval":
			return "ID_SPAWNSPEED"
		"decaydamage":
			return "ID_LIFETIME"
		"spawncount":
			return "%s ID_COUNT" % data.units.get(skill.get("unit", ""), {}).get("spawn", "")
	return key

func valueText(key, card, skill):
	match key:
		# spell only
		"castduration", "duration", "damageduration":
			if skill.has(key):
				return info_root.hud.FormatStepToSecond(skill[key])
			return null
		"damage":
			if skill.has(key):
				var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
				return "%d" % skill[key][lv]
		"radius":
			if skill.has(key):
				return info_root.hud.FormatPixelToTile(skill[key])
		"area":
			if skill.has("width") and skill.has("height"):
				return "%s x %s" % [
					info_root.hud.FormatPixelToTile(skill["width"]),
					info_root.hud.FormatPixelToTile(skill["height"]),
				]
		"count":
			if skill.has(key) and skill[key] > 1:
				return String(skill[key]).capitalize()
		# not spell
		"attackdamage", "destroydamage", \
		"hp", "shield", \
		"attackinterval", "speed", "attackrange", \
		"spawninterval", "spawncount", \
		"decaydamage":
			if not skill.has("unit"):
				return null
			var u = data.units[skill["unit"]]
			if not u.has(key):
				return null
			match key:
				"attackdamage", "destroydamage", \
				"hp", "shield":
					var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
					return "%d" % u[key][lv]
				"attackinterval", "spawninterval":
					return info_root.hud.FormatStepToSecond(u[key])
				"speed":
					return info_root.hud.FormatSpeed(u.get(key, 0))
				"attackrange":
					if data.DamageTypeIs(u.get("damagetype", 0), data.Melee):
						return "Melee"
					return info_root.hud.FormatPixelToTile(u[key])
				"decaydamage":
					var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
					var hp = float(u["hp"][lv])
					var shield = u["shield"][lv] if u.has("shield") else 0
					return "%ds" % ceil((hp + shield) / u[key] / data.StepPerSec)
				_:
					return String(u[key]).capitalize()
		# whatever
		"damagepersecond":
			var dpstep
			match card.Name:
				"astra":
					dpstep = float(skill["damage"][card.Level]) / (skill["end"] - skill["start"])
				"lancer":
					dpstep = float(skill["damage"][card.Level]) / skill["damageduration"]
				_:
					var u = data.units.get(skill.get("unit", ""), {})
					var d = u.get("attackdamage", null)
					var pstep = u.get("attackinterval", null)
					if d != null and pstep != null:
						dpstep = float(d[card.Level]) / pstep 
			if dpstep == null:
				return null
			return "%d" % [ceil(dpstep * data.StepPerSec)]
		"damagetype":
			var target_types = skill.get("targettypes", null)
			var atk_type = skill.get("attacktype", null)
			var dmg_type = skill.get("damagetype", null)
			var u = data.units.get(skill.get("unit", ""), {})
			if target_types == null:
				target_types = u.get("targettypes", {})
			if atk_type == null:
				atk_type = u.get("attacktype", "")
			if dmg_type == null:
				dmg_type = u.get("damagetype", "")
			return info_root.hud.FormatAttackType(target_types, atk_type, dmg_type)
	return null