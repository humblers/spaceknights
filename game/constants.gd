extends Node

const INT_MAX = 2147483647

# Layer Masks
const LM_DONT_COLLIDE = 0
const LM_PLAYER = 1
const LM_ENEMY = 2


const SKILL_QUEUE_LEN = 10
const SKILLS = [
	{
		"name" : "CENTRY",
		"cool" : 3,
		"energy" : 5,
		"scene" : preload("res://sentrybot/sentrybot_01/sentrybot_01.tscn"),
		"scene_vars" : {
			"hp" : 900,
			"search_range" : 6,
			"shot_range" : 6,
			"shot_cool" : 1.6,
			"bullet" : {
				"type" : 1,
				"hp" : 50,
				"speed" : 15,
				"mass" : 10000,
				"scale" : 0.8,
				"damage" : 100,
				"is_cannon" : true,
				"is_mass" : false,
			},
		},
		"is_player_child" : false,
	},
	{
		"name" : "DRONE",
		"cool" : 8,
		"energy" : 6,
		"scene" : preload("res://drone/drone_02/drone_02.tscn"),
		"is_player_child" : false,
	},
	{
		"name" : "BHOLE",
		"cool" : 5,
		"energy" : 3,
		"scene" : preload("res://blackhole/blackhole.tscn"),
		"is_player_child" : false,
	},
	{
		"name" : "ADDON",
		"cool" : 5,
		"energy" : 5,
		"scene" : preload("res://addon/addon.tscn"),
		"is_player_child" : true,
	},
	{
		"name" : "CHARGE",
		"cool" : 2,
		"energy" : 1,
		"scene" : preload("res://charge/charge.tscn"),
		"is_player_child" : false,
	}
]


const KNIGHTS = [
	{
		"type" : "default",
		"speed" : 15,
		"fire_interval" : 0.5,
		"HP_MAX" : 100, #1/40 divide
		"scene" : preload("res://knight/knight_01/knight_01.tscn"),
		"skill_cool" : 3,
		"regen_cool" : 0.3,
		"bullet" : {
			"type" : 1,
			"hp" : 20,
			"speed" : 30,
			"mass" : 1000,
			"scale" : 1,
			"damage" : 30,
			"decay_time" : 1.5,
			"is_cannon" : false,
			"is_mass" : false,
		},
	},
	{
		"type" : "3way",
		"speed" : 15,
		"fire_interval" : 0.2,
		"HP_MAX" : 100,
		"scene" : preload("res://knight/knight_03/knight_03.tscn"),
		"skill_cool" : 3,
		"regen_cool" : 1,
		"bullet" : {
			"type" : 2,
			"hp" : 20,
			"speed" : 30,
			"mass" : 1000,
			"scale" : 1,
			"damage" : 10,
			"decay_time" : 1.5,
			"is_cannon" : false,
			"is_mass" : false,
		},
	},
	{
		"type" : "multi",
		"speed" : 30,
		"fire_interval" : 0.15,
		"HP_MAX" : 100,
		"scene" : preload("res://knight/knight_04/knight_04.tscn"),
		"skill_cool" : 3,
		"regen_cool" : 1,
		"bullet" : {
			"type" : 3,
			"hp" : 10,
			"speed" : 40,
			"mass" : 1000,
			"scale" : 0.8,
			"damage" : 5,
			"decay_time" : 1.5,
			"is_cannon" : false,
			"is_mass" : false,
		},
	},
	{
		"type" : "laser",
		"speed" : 30,
		"fire_interval" : 0.2,
		"HP_MAX" : 100,
		"scene" : preload("res://knight/knight_07/knight_07.tscn"),
		"skill_cool" : 3,
		"regen_cool" : 1,
		"bullet" : {
			"type" : 4,
			"hp" : 20,
			"speed" : 30,
			"mass" : 1000,
			"scale" : 1,
			"damage" : 10,
			"decay_time" : 1.5,
			"is_cannon" : false,
			"is_mass" : false,
		},
	},
	{
		"type" : "cannon",
		"speed" : 15,
		"fire_interval" : 0.5,
		"HP_MAX" : 100,
		"scene" : preload("res://knight/knight_05/knight_05.tscn"),
		"skill_cool" : 3,
		"regen_cool" : 1,
		"bullet" : {
			"type" : 1,
			"hp" : 50,
			"speed" : 15,
			"mass" : 10000,
			"scale" : 0.8,
			"damage" : 100,
			"decay_time" : 10,
			"is_cannon" : true,
			"is_mass" : false,
		},
	},
	
]

func _ready():
	pass

func determine_layer_mask_val(is_enemy):
	return LM_ENEMY if is_enemy else LM_PLAYER

func determine_collision_mask_val(is_enemy):
	return LM_PLAYER if is_enemy else LM_ENEMY

	"""
	{
		"type" : "heavy",
		"speed" : 15,
		"fire_interval" : 1,
		"HP_MAX" : 500,
		"skill_cool" : 3,
		"regen_cool" : 3,
		"bullet" : {
			"type" : 1,
			"hp" : 80,
			"speed" : 10,
			"mass" : 10000,
			"scale" : 5,
			"damage" : 100,
			"decay_time" : 5,
			"is_cannon" : false,
			"is_mass" : true,
		},
	},
	"""
