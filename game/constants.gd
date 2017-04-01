extends Node

# Layer Masks
const LM_DONT_COLLIDE = 4
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
		"cool" : 3,
		"energy" : 2
	},
	{
		"name" : "DRONE",
		"cool" : 8,
		"energy" : 6
	},
	{
		"name" : "BHOLE",
		"cool" : 5,
		"energy" : 3
	},
	{
		"name" : "ADDON",
		"cool" : 5,
		"energy" : 5
	},
	{
		"name" : "CHARGE",
		"cool" : 2,
		"energy" : 1
	}
]


const KNIGHTS = [
	{
		"type" : "default",
		"speed" : 15,
		"fire_interval" : 0.2,
		"HP_MAX" : 3200,
		"skill_cool" : 3,
		"regen_cool" : 3,
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
		"HP_MAX" : 2000,
		"skill_cool" : 3,
		"regen_cool" : 3,
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
		"HP_MAX" : 2000,
		"skill_cool" : 3,
		"regen_cool" : 3,
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
		"HP_MAX" : 2000,
		"skill_cool" : 3,
		"regen_cool" : 3,
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
		"HP_MAX" : 6000,
		"skill_cool" : 3,
		"regen_cool" : 3,
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
