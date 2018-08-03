extends Node

const cards = {
	"archers": {
		"cost":    3000,
		"unit":    "archer",
		"count":   2,
		"offsetX": [-40, 40],
		"offsetY": [0, 0],
	},
	"fireball": {
		"cost":   4000,
		"caster": "legion",
		"damage": [300, 400, 500],
		"radius": 50,
	},
}

const units = {
	"archer": {
		"type":           "Troop",
		"layer":          "Ground",
		"mass":           6,
		"radius":         30,
		"hp":             [254],
		"sight":          500,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Ground", "Air"],
		"attackdamage":   [100, 200, 300],
		"attackrange":    500,
		"attackinterval": 30,
		"preattackdelay": 0,
		"bulletlifetime": 20,
	},
	"legion": {
		"mass":           6,
		"radius":         50,
		"type":           "Knight",
		"layer":          "Ground",
		"hp":             [2000],
		"sight":          500,
		"speed":          250,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Ground", "Air"],
		"attackdamage":   [100],
		"attackrange":    500,
		"attackinterval": 40,
		"preattackdelay": 1,
		"bulletlifetime": 20,
		"transformdelay": 10,
		"skill":          "fireball",
	},
}
