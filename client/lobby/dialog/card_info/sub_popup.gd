extends TextureButton

const STAT_ORDER = [
	"castduration", "duration", "damageduration",
	"damage", "attackdamage",
	"destroydamage",
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
	"knightdamage",
	"count", "spawncount",
]

export(NodePath) onready var info_root = get_node(info_root)
export(NodePath) onready var stat_container = get_node(stat_container)
export(NodePath) onready var description_label = get_node(description_label)

export(NodePath) onready var left_point = get_node(left_point)
export(NodePath) onready var right_point = get_node(right_point)

export(NodePath) onready var wing_skill_dsc = get_node(wing_skill_dsc)
export(NodePath) onready var add_description_label = get_node(add_description_label)

func Invalidate(card, pressed):
	self.rect_global_position = pressed.sub_popup_pos.global_position
	left_point.visible = pressed.is_left
	right_point.visible = not pressed.is_left
	description_label.visible = pressed.sub_info.type == "leader"
	stat_container.visible = pressed.sub_info.type == "wing"
	wing_skill_dsc.visible = pressed.sub_info.type == "wing"
	if pressed.sub_info.type == "leader":
		description_label.SetText("ID_LEADER_SKILL_%s" % card.Name.to_upper())
	else:
		add_description_label.SetText("ID_WING_SKILL_%s" % card.Name.to_upper())
		var item_nodes = stat_container.get_children()
		var pointer = 0
		for key in STAT_ORDER:
			var value_text = valueText(key, card, pressed.sub_info)
			if value_text == null:
				continue
			var key_text = keyText(key, pressed.sub_info)
			var icon_key = key
			var u = data.units.get(pressed.sub_info.get("unit", ""), {})
			if pressed.sub_info.get("radius", null) != null:
				match key:
					"damage":
						icon_key = "areadamage"
					"damagepersecond":
						icon_key = "areadps"
			if pressed.sub_info.has("unit"):
				var spawnunit = data.units[pressed.sub_info["unit"]]
				if spawnunit.has("damageradius"):
					match key:
						"attackdamage":
							icon_key = "areadamage"
						"damagepersecond":
							icon_key = "areadps"
			var icon_texture = loading_screen.GetStatIcon("contents", icon_key)
			item_nodes[pointer].Invalidate(icon_texture, key_text, value_text, null)
			pointer += 1
			if pointer >= info_root.MAX_STAT_COUNT:
				break
		for i in range(info_root.MAX_STAT_COUNT):
			item_nodes[i].visible = i < pointer
	self.visible = true

func keyText(key, skill):
	match key:
		"attackdamage":
			var t = "ID_DAMAGE"
			if not skill.has("unit"):
				return t
			var u = data.units[skill["unit"]]
			if not u.has(key):
				return t
			if u.has("damageradius"):
				t = "ID_AREADAMAGE"
			return t
		"area":
			return "ID_AREA"
		"attackinterval":
			return "ID_ATTACKSPEED"
		"attackrange":
			return "ID_RANGE"
		"castduration":
			return "ID_CASTDURATION"
		"chargedattackdamage", "powerattackdamage", "absorbdamage":
			return "ID_SKILLDAMAGE"
		"damage":
			var t = "ID_DAMAGE"
			if skill.get("radius", null) != null:
				t = "ID_AREADAMAGE"
			return t
		"damageduration", "duration":
			return "ID_DAMAGEDURATION"
		"damagepersecond":
			var t = "ID_DPS"
			if not skill.has("unit"):
				return t
			var u = data.units[skill["unit"]]
			if u.has("damageradius"):
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
		"knightdamage":
			return "ID_KNIGHTDAMAGE"
		"radius":
			return "ID_RADIUS"
		"shield":
			return "ID_BARRIER"
		"spawninterval":
			return "ID_SPAWNSPEED"
		"count":
			return "ID_COUNT"
		"spawncount":
			return "ID_%s_COUNT" % data.units.get(skill.get("unit", ""), {}).get("spawn", "").to_upper()
		"speed":
			return "ID_SPEED"
		_:
			print("key text format failed")

func valueText(key, card, skill):
	match key:
		# spell only
		"castduration", "duration", "damageduration", "freezeduration":
			if skill.has(key):
				return static_func.FormatStepToSecond(skill[key])
			return null
		"damage":
			if skill.has(key):
				var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
				return "%d" % skill[key][lv]
		"knightdamage":
			if skill.has("damagetype"):
				if data.DamageTypeIs(skill["damagetype"], data.DecreaseOnKnight):
					var lv = card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity]
					return "%d" % round(skill["damage"][lv] * data.DecreasedDamageRatioOnKnightBuilding / 100)
			return null
		"radius":
			if skill.has(key):
				return static_func.FormatPixelToTile(skill[key])
		"area":
			if skill.has("width") and skill.has("height"):
				return "%s x %s" % [
					static_func.FormatPixelToTile(skill["width"]),
					static_func.FormatPixelToTile(skill["height"]),
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
					return static_func.FormatStepToSecond(u[key])
				"speed":
					return static_func.FormatSpeed(u.get(key, 0))
				"attackrange":
					if data.DamageTypeIs(u.get("damagetype", 0), data.Melee):
						return "ID_MELEE"
					return static_func.FormatPixelToTile(u[key])
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
				dmg_type = u.get("damagetype", 0)
			return static_func.FormatAttackType(target_types, atk_type, dmg_type)
	return null
