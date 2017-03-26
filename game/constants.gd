extends Node

const SKILL_QUEUE_LEN = 10
const TURRET = 1
const DRONE = 2
const BLACKHOLE=3

const knights = {
	"default" : {
		"speed" : 15,
		"interval" : 0.2,
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
	"heavy" : {
		"speed" : 15,
		"interval" : 0.2,
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
	"3way" : {
		"speed" : 15,
		"interval" : 0.2,
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
	"laser" : {
		"speed" : 15,
		"interval" : 0.2,
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
	"multi" : {
		"speed" : 15,
		"interval" : 0.2,
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
	"cannon" : {
		"speed" : 15,
		"interval" : 0.2,
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
}

func _ready():
	pass
