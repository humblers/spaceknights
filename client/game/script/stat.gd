extends Node

const ShieldRegenPerStep = 2
const HoverKnightTileOffsetX = 2

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
		"cost":    5000,
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
		"offsetX": [-40, 0, 40, -40, 0, 40],
		"offsetY": [-20, -20, -20, 20, 20, 20],
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
	"trainee": {
		"cost":    2000,
		"unit":    "trainee",
		"count":   3,
		"offsetX": [-30, 30, 0],
		"offsetY": [30, 30, 0],
	},
	"starfire": {
		"cost":    4000,
		"unit":    "starfire",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
	"threestarfires": {
		"cost":    9000,
		"unit":    "starfire",
		"count":   3,
		"offsetX": [-60, 60, 0],
		"offsetY": [60, 60, 0],
	},
	"pixie": {
		"cost":    1000,
		"unit":    "pixie",
		"count":   3,
		"offsetX": [-30, 30, 0],
		"offsetY": [30, 30, 0],
	},
	"gargoyleking": {
		"cost":    3000,
		"unit":    "gargoyleking",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
	"berserker": {
		"cost":    4000,
		"unit":    "berserker",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
	"ogre": {
		"cost":    7000,
		"unit":    "ogre",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
	"wasp": {
		"cost":    5000,
		"unit":    "wasp",
		"count":   1,
		"offsetX": [0],
		"offsetY": [0],
	},
}

const passives = {
	"gatherfootman" : {
		"unit":         "footman",
		"count":        4,
		"offsetX":      [-30, 30, -30, 30],
		"offsetY":      [-30, -30, 30, 30],
		"perstep":      300,
	},
	"lemming" : {
		"unit":         "footman",
		"count":        1,
		"offsetX":      150,
		"perdeaths":    4,
	},
	"moredamage": {
		"attackdamageratio": [110, 130, 140],
	},
	"morerange": {
		"attackrangeratio": [120, 130, 140],
	},
	"readycannon": {
		"unit":         "cannon",
		"count":        2,
		"posX":         [325, 675],	 # pos based on blue side
		"posY":         [1075, 1075],
		"hpratio":      [300, 310, 320],
	},
	"reinforce": {
		"hpratio":      [120, 130, 140],
	},
}

const units = {
	"archer": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         20,
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
		"radius":         60,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [24000],
		"sight":          350,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [50],
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"active":          "cannon",
		"passive":         "readycannon",
	},
	"tombstone": {
		"mass":           1000,
		"radius":         80,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [24000],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [50],
		"attackrange":    330,
		"attackinterval": 10,
		"active":          "barrack",
		"passive":         "lemming",
	},
	"cannon": {
		"type":           "Building",
		"layer":          "Normal",
		"mass":           0,
		"radius":         30,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             [350],
		"sight":          350,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [60],
		"attackrange":    350,
		"attackinterval": 8,
		"preattackdelay": 0,
		"bulletlifetime": 4,
		"decaydamage":    1,
	},
	"barrack": {
		"type":           "Building",
		"layer":          "Normal",
		"mass":           0,
		"radius":         60,
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
		"radius":         25,
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
		"radius":         40,
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
		"attackinterval": 30,
		"preattackdelay": 15,
		"powerattackdamage":    [100, 200, 300],
		"powerattackinterval":  50,
		"powerattackpredelay":  33,
		"powerattackfrequency": 3,
		"powerattackradius":    300,
		"powerattackforce":     3000,
	},
	"jouster": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         30,
		"hp":             [1100],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [220, 70, 100],
		"attackrange":    40,
		"attackinterval": 15,
		"preattackdelay": 5,
		"chargedelay":           20,
		"chargedmovespeed":      300,
		"chargedattackdamage":   [400, 450, 550],
		"chargedattackinterval": 6,
		"chargedattackpredelay": 3,
	},
	"gargoyle": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         25,
		"hp":             [90],
		"shield":         [50],
		"sight":          350,
		"speed":          150,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [40, 60, 90],
		"attackrange":    100,
		"attackinterval": 10,
		"preattackdelay": 5,
	},
	"giant": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           60,
		"radius":         60,
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
		"radius":         45,
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
		"active":         "fireball",
		"passive":        "moredamage",
	},
	"judge": {
		"mass":           0,
		"radius":         35,
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
		"active":         "bulletrain",
		"passive":        "morerange",
	},
	"nagmash": {
		"mass":           1000,
		"radius":         70,
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
		"radius":         70,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [24000],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [50],
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"active":         "megalaser",
		"passive":        "reinforce",
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
		"absorbforce":    2000,
		"absorbdamage":   2,
		"absorbradius":   500,
	},
	"felhound": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           10,
		"radius":         15,
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
		"radius":         35,
		"hp":             [800],
		"shield":         300,
		"sight":          400,
		"speed":          150,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [300, 450, 600],
		"attackrange":    300,
		"attackinterval": 36,
		"preattackdelay": 0,
		"bulletlifetime": 30,
	},
	"trainee": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         20,
		"hp":             [50],
		"sight":          350,
		"speed":          200,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [48, 70, 100],
		"attackrange":    40,
		"attackinterval": 12,
		"preattackdelay": 5,
	},
	"starfire": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         30,
		"hp":             [340],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [100, 60, 90],
		"attackrange":    350,
		"attackinterval": 11,
		"preattackdelay": 0,
		"bulletlifetime": 4,
	},
	"pixie": {
		"type":           "Troop",
		"layer":          "Ether",
		"mass":           6,
		"radius":         15,
		"hp":             [30],
		"sight":          350,
		"speed":          150,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [60, 70, 100],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 4,
	},
	"gargoyleking": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         35,
		"hp":             [395],
		"shield":         [100],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [147, 60, 90],
		"attackrange":    100,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"berserker": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         30,
		"hp":             [600],
		"sight":          350,
		"speed":          150,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [325, 70, 100],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"ogre": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         35,
		"hp":             [2610],
		"sight":          350,
		"speed":          75,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [500, 70, 100],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"wasp": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         25,
		"hp":             [1050],
		"shield":         [500],
		"sight":          300,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attackdamage":   [600, 60, 90],
		"attackrange":    75,
		"attackinterval": 10,
		"preattackdelay": 7,
		"destroydamage":  [600],
		"destroyradius":  100,
	},
}
