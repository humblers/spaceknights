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
	if pressed.sub_info.type == "wing":
		var item_nodes = stat_container.get_children()
		var pointer = 0
		for key in STAT_ORDER:
			var value_text = valueText(key, card, pressed.sub_info)
			if value_text == null:
				continue
			var key_text = keyText(key, pressed.sub_info)
			var icon_texture = info_root.IconTexture(key)
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
			return "Cast Duration"
		"damageduration":
			return "Damage Duration"
		"damage":
			return "Area Damage"
		"attackdamage":
			var t = "Damage"
			if skill.get("unit", {}).get("damageradius", null) != null:
				t = "Area %s" % t
			return t
		"damagepersecond":
			var t = "Damage Per Second"
			if skill.has("damage") or skill.get("unit", {}).get("damageradius", null) != null:
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
		"freezeduration":
			return "Freeze Duration"
		"spawninterval":
			return "Spawn Speed"
		"decaydamage":
			return "Lifetime"
		"spawncount":
			return "%s Count" % data.units.get(skill.get("unit", ""), {}).get("spawn", "")
	return key

func valueText(key, card, skill):
	match key:
		# spell only
		"castduration", "duration", "damageduration":
			if skill.has(key):
				return info_root.FormatStepToSecond(skill[key])
			return null
		"damage":
			if skill.has(key):
				return "%d" % skill[key][card.Level]
		"radius":
			if skill.has(key):
				return info_root.FormatPixelToTile(skill[key])
		"area":
			if skill.has("width") and skill.has("height"):
				return "%s x %s" % [
					info_root.FormatPixelToTile(skill["width"]),
					info_root.FormatPixelToTile(skill["height"]),
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
					return "%d" % u[key][card.Level]
				"attackinterval", "spawninterval":
					return info_root.FormatStepToSecond(u[key])
				"speed":
					return info_root.FormatSpeed(u.get(key, 0))
				"attackrange":
					var attack_type = u.get("attacktype", "")
					if attack_type == data.Melee:
						return attack_type
					return info_root.FormatPixelToTile(u[key])
				"decaydamage":
					var hp = float(u["hp"][card.Level])
					var shield = u["shield"][card.Level] if u.has("shield") else 0
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
			return info_root.FormatAttackType(target_types, atk_type, dmg_type)
	return null