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
	"cannon": {
		"cost":    1000,
		"spawn": {
			"unit": "cannon",
			"count": 1,
			"offsetX": [0],
			"offsetY": [0],
		},
		"caster":   "archsapper",
		"castduration": 100,
		"precastdelay": 82,
	},
	"footmans": {
		"cost":    5000,
		"unit":    "footman",
		"count":   4,
		"offsetX": [-30, 30, -30, 30],
		"offsetY": [-30, -30, 30, 30],
	},
	"fireball": {
		"cost":   2000,
		"caster": "legion",
		"damage": [300, 400, 500],
		"radius": 70,
		"castduration": 40,
		"precastdelay": 20,
	},
	"bulletrain": {
		"cost":   2000,
		"caster": "judge",
		"damage": [300, 400, 500],
		"radius": 70,
		"castduration": 50,
		"precastdelay": 20,
	},
	"gargoylehorde": {
		"cost":    6000,
		"unit":    "gargoyle",
		"count":   6,
		"offsetX": [-30, 0, 30, -30, 0, 30],
		"offsetY": [-15, -15, -15, 15, 15, 15],
	},
	"giant": {
		"cost": 5000,
		"unit": "giant",
		"count": 1,
		"offsetX": [0],
		"offsetY": [0],
	},
	"unload": {
		"cost":         2000,
		"spawn":        "footmans",
		"caster":       "nagmash",
		"castduration": 100,
		"precastdelay": 52,
	},
	"megalaser": {
		"cost":   2000,
		"caster": "astra",
		"duration": 80,
		"start": 10,
		"end": 58,
		"damage": [10, 15, 20],
		"width": 25,
		"height": 500,
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
	"archsapper": {
		"mass":           0,
		"radius":         80,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2000],
		"sight":          350,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [150],
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"skill":          "cannon",
	},
	"cannon": {
		"type":           "Building",
		"layer":          "Normal",
		"mass":           0,
		"radius":         50,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             [360],
		"sight":          350,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [40],
		"attackrange":    300,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 4,
		"decaydamage":    1,
	},
	"footman": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         30,
		"hp":             [1000],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [40, 70, 100],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 5,
	},
	"gargoyle": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         15,
		"hp":             [200],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [20, 60, 90],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 5,
	},
	"giant": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           60,
		"radius":         55,
		"hp":             [1500],
		"sight":          350,
		"speed":          50,	#pixels per second
		"targettypes":    ["Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [500, 60, 90],
		"attackrange":    40,
		"attackinterval": 30,
		"preattackdelay": 8,
	},
	"legion": {
		"mass":           0,
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
		"skill":          "fireball",
	},
	"judge": {
		"mass":           0,
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
		"bulletlifetime": 5,
		"skill":          "bulletrain",
	},
	"nagmash": {
		"mass":           600,
		"radius":         80,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2000],
		"sight":          350,
		"speed":          100,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [200],
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"skill":          "unload",
	},
	"astra": {
		"mass":           600,
		"radius":         80,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2000],
		"sight":          350,
		"speed":          100,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [200],
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"skill":          "megalaser",
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
