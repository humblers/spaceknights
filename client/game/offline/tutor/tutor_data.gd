extends Reference

# use prediction for opposite unit located in bottom area
const LEFT_DEST = Vector2(250, 550)
const RIGHT_DEST = Vector2(750, 550)

const DONOT_BE_LESS_THAN_OPPISITE_ENERGY = 2000

const DEFENSE_TYPE_BUILDING_DECISON_COST = 4000
const SPAWN_TYPE_BUILDING_DECISION_COST = 5000

const INSTANT_DAMAGE_SKILL_VALUE_MIN = 3
static func value_of_instant_damage_skill(unit, skill, level):
	var shield = unit.get("shield")
	if shield == null:
		shield = 0
	return min(skill["damage"][level] / (unit.hp + shield), 1)

const DOT_DAMAGE_SKILL_VALUE_MIN = 2
static func value_of_dot_damage_skill(unit, skill, level):
	return 1

const FREEZE_SKILL_VALUE_MIN = 3
static func value_of_freeze_skill(unit, skill, level):
	return 1
const FREEZE_COMBINATION_REQUIRED_ENERGY = 4000

var units

func _init():
	units = {}
	for card in stat.cards.keys():
		var unit = stat.cards[card].Unit
		if stat.units[unit]["type"] == "Knight":
			units[unit] = { "Cost": 0 }
			var wing_skill = stat.units[unit]["skill"]["wing"]
			if wing_skill.has("unit"):
				units[wing_skill["unit"]] = { "Cost": stat.cards[card].Cost }
			continue
		var cost_per_unit = stat.cards[card].Cost / stat.cards[card].Count
		if units.has(unit) and units[unit].Cost > cost_per_unit:
			continue
		units[unit] = { "Cost": cost_per_unit }

func new_dict_for_analyze():
	return {
		"Blue": {
			"top_left": {
				"cost": 0,
				"front_unit": null,
			},
			"top_right": {
				"cost": 0,
				"front_unit": null,
			},
			"bot_left": {
				"cost": 0,
				"front_unit": null,
			},
			"bot_right": {
				"cost": 0,
				"front_unit": null,
			},
			"total_cost": 0,
		},
		"Red": {
			"top_left": {
				"cost": 0,
				"front_unit": null,
			},
			"top_right": {
				"cost": 0,
				"front_unit": null,
			},
			"bot_left": {
				"cost": 0,
				"front_unit": null,
			},
			"bot_right": {
				"cost": 0,
				"front_unit": null,
			},
			"total_cost": 0,
		},
		"unit_positions" : {},
	}