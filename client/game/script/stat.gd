extends Node

const ShieldRegenPerStep = 2

const cards = {
	"archers": {
		"cost":    3000,
		"unit":    "archer",
		"count":   2,
		"offsetX": [-40, 40],
		"offsetY": [0, 0],
	},
	"cannon": {
		"cost":    3000,
		"unit": "cannon",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
		"caster":   "archsapper",
		"castduration": 100,
		"precastdelay": 82,
	},
	"barrack": {
		"cost":         7000,
		"unit": "barrack",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
		"caster":       "tombstone",
		"castduration": 50,
		"precastdelay": 20,
	},
	"footmans": {
		"cost":    5000,
		"unit":    "footman",
		"count":   4,
		"offsetX": [-30, 30, -30, 30],
		"offsetY": [-30, -30, 30, 30],
	},
	"enforcer": {
		"cost":    4000,
		"unit":    "enforcer",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
	"panzerkunstler": {
		"cost":    5000,
		"unit":    "panzerkunstler",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
	"jouster": {
		"cost":    4000,
		"unit":    "jouster",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
	"fireball": {
		"cost":   4000,
		"caster": "legion",
		"damage": [325, 400, 500],
		"radius": 70,
		"castduration": 40,
		"precastdelay": 20,
	},
	"bulletrain": {
		"cost":   3000,
		"caster": "judge",
		"damage": [300, 400, 500],
		"radius": 70,
		"castduration": 50,
		"precastdelay": 20,
	},
	"gargoylehorde": {
		"cost":    5000,
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
		"cost":         4000,
		"unit":        "footman",
		"count":   4,
		"offsetX": [-30, 30, -30, 30],
		"offsetY": [-30, -30, 30, 30],
		"caster":       "nagmash",
		"castduration": 100,
		"precastdelay": 52,
	},
	"megalaser": {
		"cost":   4000,
		"caster": "astra",
		"duration": 80,
		"start": 10,
		"end": 58,
		"damage": [10, 15, 20],
		"width": 25,
		"height": 500,
	},
	"psabu": {
		"cost":    7000,
		"unit":    "psabu",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
	"felhound": {
		"cost":    2000,
		"unit":    "felhound",
		"count":   5,
		"offsetX": [-60, 0, 60, -30, 30],
		"offsetY": [-30, -30, -30, 30, 30],
	},
	"shadowvision": {
		"cost":    4000,
		"unit":    "shadowvision",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
}

const passives = {
	"gatherfootman" : {
		"unit":			"footman",
		"count":		4,
		"offsetX":		[-30, 30, -30, 30],
		"offsetY":		[-30, -30, 30, 30],
		"perstep":		300,
	},
	"readycannon": {
		"unit":			"cannon",
		"count":		2,
		"posX":			[325, 675],	 # pos based on blue side
		"posY":			[1075, 1075],
	},
}

const units = {
	"archer": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         30,
		"hp":             [125],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [40, 60, 90],
		"attackrange":    300,
		"attackinterval": 12,
		"preattackdelay": 0,
		"bulletlifetime": 4,
	},
	"archsapper": {
		"mass":           0,
		"radius":         80,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [50],
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"active":          "cannon",
		"passive":    "readycannon",
	},
	"tombstone": {
		"mass":           1000,
		"radius":         80,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [50],
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"active":          "barrack",
	},
	"cannon": {
		"type":           "Building",
		"layer":          "Normal",
		"mass":           0,
		"radius":         50,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             [350],
		"sight":          350,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [60],
		"attackrange":    300,
		"attackinterval": 8,
		"preattackdelay": 0,
		"bulletlifetime": 4,
		"decaydamage":    1,
	},
	"barrack": {
		"type":           "Building",
		"layer":          "Normal",
		"mass":           0,
		"radius":         50,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             [1100],
		"spawn":          "footman",
		"spawninterval":  140,
		"spawncount":     2,
		"spawnoffsetX":   [-20, 20],
		"spawnoffsetY":   [0, 0],
		"decaydamage":    1,
	},
	"footman": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         30,
		"hp":             [300],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [75, 70, 100],
		"attackrange":    40,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"enforcer": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         30,
		"hp":             [880],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [312, 70, 100],
		"attackrange":    40,
		"attackinterval": 40,
		"preattackdelay": 10,
	},
	"panzerkunstler": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         30,
		"hp":             [800],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [500, 70, 100],
		"attackrange":    40,
		"attackinterval": 40,
		"preattackdelay": 33,
	},
	"jouster": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         30,
		"hp":             [720],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [125, 70, 100],
		"attackrange":    40,
		"attackinterval": 15,
		"preattackdelay": 5,
		"transformdelay": 10,
	},
	"gargoyle": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         15,
		"hp":             [90],
		"shield":         [50],
		"sight":          350,
		"speed":          150,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [40, 60, 90],
		"attackrange":    40,
		"attackinterval": 10,
		"preattackdelay": 5,
	},
	"giant": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           60,
		"radius":         55,
		"hp":             [2000],
		"sight":          350,
		"speed":          75,	#pixels per second
		"targettypes":    ["Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [163, 60, 90],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 8,
	},
	"legion": {
		"mass":           0,
		"radius":         50,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"speed":          800,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [10],
		"attackrange":    350,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"active":          "fireball",
	},
	"judge": {
		"mass":           0,
		"radius":         50,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [50],
		"attackrange":    350,
		"attackinterval": 10,
		"preattackdelay": 1,
		"bulletlifetime": 5,
		"active":          "bulletrain",
	},
	"nagmash": {
		"mass":           1000,
		"radius":         80,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [50],
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"active":          "unload",
		"passive":    "gatherfootman",
	},
	"astra": {
		"mass":           1000,
		"radius":         80,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [50],
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"active":          "megalaser",
	},
	"psabu": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           60,
		"radius":         40,
		"hp":             [2700],
		"shield":         [500],
		"sight":          350,
		"speed":          100,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [800, 60, 90],
		"attackrange":    30,
		"attackinterval": 50,
		"attackradius":   80,
		"preattackdelay": 28,
	},
	"felhound": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           10,
		"radius":         30,
		"hp":             [32],
		"shield":         [50],
		"sight":          350,
		"speed":          200,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [96, 60, 90],
		"attackrange":    30,
		"attackinterval": 30,
		"preattackdelay": 10,
	},
	"shadowvision": {
		"type":           "Troop",
		"layer":          "Ether",
		"mass":           20,
		"radius":         50,
		"hp":             [800],
		"shield":         300,
		"sight":          400,
		"speed":          150,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [300, 450, 600],
		"attackrange":    350,
		"attackinterval": 36,
		"preattackdelay": 0,
		"bulletlifetime": 30,
	},
}
