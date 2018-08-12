extends Node

const ShieldRegenPerStep = 2

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
	"shadowvision": {
		"cost":    3000,
		"unit":    "shadowvision",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
}

const units = {
	"archer": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         30,
		"hp":             [254],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
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
		"layer":          "Normal",
		"hp":             [2000],
		"sight":          350,
		"speed":          800,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [50],
		"attackrange":    350,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"transformdelay": 5,
		"skill":          "fireball",
	},
	"shadowvision": {
		"type":           "Troop",
		"layer":          "Ether",
		"mass":           20,
		"radius":         50,
		"hp":             [300],
		"shield":         300,
		"sight":          400,
		"speed":          80,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [300, 450, 600],
		"attackrange":    350,
		"attackinterval": 40,
		"preattackdelay": 0,
		"bulletlifetime": 30,
	},
}
