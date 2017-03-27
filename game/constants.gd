extends Node

# Layer Masks
const LM_PLAYER = 1
const LM_ENEMY = 2

const SKILL_QUEUE_LEN = 10
const TURRET = 1
const DRONE = 2
const BLACKHOLE = 3
const ADDON = 4
const CHARGE = 5

const SKILLS = [
	{
		"name" : "TURRET",
		"cool" : 5
	},
	{
		"name" : "DRONE",
		"cool" : 5
	},
	{
		"name" : "BLACKHOLE",
		"cool" : 15
	},
	{
		"name" : "ADDON",
		"cool" : 5
	},
	{
		"name" : "CHARGE",
		"cool" : 2
	}
]

const KNIGHTS = [
	{
		"type" : "default",
		"speed" : 15,
		"fire_interval" : 0.2,
		"HP_MAX" : 300,
		"skill_cool" : 3,
		"regen_cool" : 3,
		"bullet" : {
			"type" : 1,
			"hp" : 20,
			"speed" : 30,
			"mass" : 1000,
			"scale" : 1,
			"damage" : 22,
			"decay_time" : 1.5,
			"is_cannon" : false,
			"is_mass" : false,
		},
	},
	{
		"type" : "3way",
		"speed" : 15,
		"fire_interval" : 0.2,
		"HP_MAX" : 300,
		"skill_cool" : 3,
		"regen_cool" : 3,
		"bullet" : {
			"type" : 2,
			"hp" : 20,
			"speed" : 30,
			"mass" : 1000,
			"scale" : 1,
			"damage" : 7,
			"decay_time" : 1.5,
			"is_cannon" : false,
			"is_mass" : false,
		},
	},
	{
		"type" : "multi",
		"speed" : 30,
		"fire_interval" : 0.1,
		"HP_MAX" : 300,
		"skill_cool" : 3,
		"regen_cool" : 3,
		"bullet" : {
			"type" : 3,
			"hp" : 10,
			"speed" : 50,
			"mass" : 1000,
			"scale" : 0.8,
			"damage" : 2,
			"decay_time" : 1.5,
			"is_cannon" : false,
			"is_mass" : false,
		},
	},
	{
		"type" : "laser",
		"speed" : 30,
		"fire_interval" : 0.2,
		"HP_MAX" : 300,
		"skill_cool" : 3,
		"regen_cool" : 3,
		"bullet" : {
			"type" : 4,
			"hp" : 20,
			"speed" : 30,
			"mass" : 1000,
			"scale" : 1,
			"damage" : 15,
			"decay_time" : 1.5,
			"is_cannon" : false,
			"is_mass" : false,
		},
	},
	{
		"type" : "heavy",
		"speed" : 15,
		"fire_interval" : 1,
		"HP_MAX" : 300,
		"skill_cool" : 3,
		"regen_cool" : 3,
		"bullet" : {
			"type" : 1,
			"hp" : 100,
			"speed" : 10,
			"mass" : 10000,
			"scale" : 10,
			"damage" : 100,
			"decay_time" : 5,
			"is_cannon" : false,
			"is_mass" : true,
		},
	},
	{
		"type" : "cannon",
		"speed" : 15,
		"fire_interval" : 1,
		"HP_MAX" : 300,
		"skill_cool" : 3,
		"regen_cool" : 3,
		"bullet" : {
			"type" : 1,
			"hp" : 100,
			"speed" : 10,
			"mass" : 10000,
			"scale" : 1.5,
			"damage" : 100,
			"decay_time" : 5,
			"is_cannon" : true,
			"is_mass" : false,
		},
	},
]

func _ready():
	pass
