extends Node

const cards = {
	"archers": {
		"cost":    1000,
		"unit":    "archer",
		"count":   2,
		"offsetX": [-40, 40],
		"offsetY": [0, 0],
	},
	"fireball": {
		"cost":   2000,
		"caster": "legion",
		"damage": [300, 400, 500],
		"radius": 70,
	},
}

const units = {
	"archer": {
		"type":           "Troop",
		"layer":          "Ground",
		"mass":           6,
		"radius":         30,
		"hp":             [254],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Ground", "Air"],
		"attackdamage":   [30, 60, 90],
		"attackrange":    300,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 4,
	},
	"legion": {
		"mass":           6,
		"radius":         50,
		"type":           "Knight",
		"layer":          "Ground",
		"hp":             [2000],
		"sight":          350,
		"speed":          800,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Ground", "Air"],
		"attackdamage":   [50],
		"attackrange":    330,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"transformdelay": 5,
		"skill":          "fireball",
	},
}
