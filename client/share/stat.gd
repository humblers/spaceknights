extends Node

const ShieldRegenPerStep = 2
const HoverKnightTileOffsetX = 2
const SlowPercent = 50

var cards = {
# units
	"archengineer": {
		"Cost":    5000,
		"Unit":    "archengineer",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"archers": {
		"Cost":    3000,
		"Unit":    "archer",
		"Count":   2,
		"OffsetX": [-40, 40],
		"OffsetY": [0, 0],
		"Rarity":  "Common",
	},
	"archsapper": {
		"Cost":    3000,
		"Unit":    "archsapper",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Common",
	},
	"astra": {
		"Cost":    4000,
		"Unit":    "astra",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Legendary",
	},
	"berserker": {
		"Cost":    4000,
		"Unit":    "berserker",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"blaster": {
		"Cost": 3000,
		"Unit": "blaster",
		"Count": 1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Common",
	},
	"champion": {
		"Cost":    4000,
		"Unit":    "champion",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Epic",
	},
	"drillram": {
		"Cost": 4000,
		"Unit": "drillram",
		"Count": 1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"enforcer": {
		"Cost":    4000,
		"Unit":    "enforcer",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"felhound": {
		"Cost":    2000,
		"Unit":    "felhound",
		"Count":   5,
		"OffsetX": [-60, 0, 60, -30, 30],
		"OffsetY": [-30, -30, -30, 30, 30],
		"Rarity":  "Common",
	},
	"footmans": {
		"Cost":    5000,
		"Unit":    "footman",
		"Count":   4,
		"OffsetX": [-30, 30, -30, 30],
		"OffsetY": [-30, -30, 30, 30],
		"Rarity":  "Common",
	},
	"frost": {
		"Cost":    4000,
		"Unit":    "frost",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Epic",
	},
	"gargoyles": {
		"Cost":    3000,
		"Unit":    "gargoyle",
		"Count":   3,
		"OffsetX": [-20, 20, 0],
		"OffsetY": [20, 20, 0],
		"Rarity":  "Common",
	},
	"gargoylehorde": {
		"Cost":    5000,
		"Unit":    "gargoyle",
		"Count":   6,
		"OffsetX": [-40, 0, 40, -40, 0, 40],
		"OffsetY": [-20, -20, -20, 20, 20, 20],
		"Rarity":  "Common",
	},
	"gargoyleking": {
		"Cost":    3000,
		"Unit":    "gargoyleking",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"giant": {
		"Cost": 5000,
		"Unit": "giant",
		"Count": 1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"ironcoffin": {
		"Cost":    5000,
		"Unit":    "ironcoffin",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"jouster": {
		"Cost":    5000,
		"Unit":    "jouster",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Epic",
	},
	"judge": {
		"Cost":   3000,
		"Unit":    "judge",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Common",
	},
	"lancer": {
		"Cost":    4000,
		"Unit":    "lancer",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Epic",
	},
	"legion": {
		"Cost":    4000,
		"Unit":    "legion",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"nagmash": {
		"Cost":    4000,
		"Unit":   "nagmash",
		"Count":   4,
		"OffsetX": [-30, 30, -30, 30],
		"OffsetY": [-30, -30, 30, 30],
		"Rarity":  "Epic",
	},
	"ogre": {
		"Cost":    7000,
		"Unit":    "ogre",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Epic",
	},
	"panzerkunstler": {
		"Cost":    5000,
		"Unit":    "panzerkunstler",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Epic",
	},
	"pixie": {
		"Cost":    1000,
		"Unit":    "pixie",
		"Count":   3,
		"OffsetX": [-30, 30, 0],
		"OffsetY": [30, 30, 0],
		"Rarity":  "Rare",
	},
	"pixieking": {
		"Cost":    3000,
		"Unit":    "pixieking",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"psabu": {
		"Cost":    7000,
		"Unit":    "psabu",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Legendary",
	},
	"sentry": {
		"Cost":    2000,
		"Unit":    "sentry",
		"Count":   3,
		"OffsetX": [-30, 30, 0],
		"OffsetY": [30, 30, 0],
		"Rarity":  "Common",
	},
	"shadowvision": {
		"Cost":    4000,
		"Unit":    "shadowvision",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Epic",
	},
	"starfire": {
		"Cost":    4000,
		"Unit":    "starfire",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"threestarfires": {
		"Cost":    9000,
		"Unit":    "starfire",
		"Count":   3,
		"OffsetX": [-60, 60, 0],
		"OffsetY": [60, 60, 0],
		"Rarity":  "Rare",
	},
	"tombstone": {
		"Cost":    6000,
		"Unit":    "tombstone",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Rare",
	},
	"trainee": {
		"Cost":    2000,
		"Unit":    "trainee",
		"Count":   3,
		"OffsetX": [-30, 30, 0],
		"OffsetY": [30, 30, 0],
		"Rarity":  "Rare",
	},
	"wasp": {
		"Cost":    5000,
		"Unit":    "wasp",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  "Epic",
	},
}

var units = {
	"archengineer": {
		"mass":           0,
		"radius":         75,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Bullet",
		"damagetype":    "NormalDamage",
		"attackdamage":   [100],
		"attackrange":    330,
		"attackinterval": 20,
		"preattackdelay": 10,
		"bulletlifetime": 10,
		"skill": {
			"wing": {
				"name":         "blastturret",
				"unit":         "blastturret",
				"castduration": 50,
				"precastdelay": 38,
			},
			"leader": {
				"arearatio":    120,
			},
		},
	},
	"archer": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         20,
		"hp":             [180],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Bullet",
		"damagetype":    "NormalDamage",
		"attackdamage":   [90, 60, 90],
		"attackrange":    250,
		"attackinterval": 12,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"archsapper": {
		"mass":           0,
		"radius":         75,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Bullet",
		"damagetype":    "NormalDamage",
		"attackdamage":   [75],
		"attackrange":    350,
		"attackinterval": 15,
		"preattackdelay": 5,
		"bulletlifetime": 7,
		"skill": {
			"wing": {
				"name":         "cannon",
				"unit":         "cannon",
				"castduration": 50,
				"precastdelay": 39,
			},
			"leader": {
				"name":         "readycannon",
				"unit":         "cannon",
				"count":        2,
				"posX":         [325, 675],	 # pos based on blue side
				"posY":         [1075, 1075],
				"hpratio":      [300, 310, 320],
			},
		},
	},
	"astra": {
		"mass":           0,
		"radius":         95,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Laser",
		"damagetype":    "NormalDamage",
		"attackdamage":   [5],
		"attackrange":    350,
		"attackinterval": 1,
		"skill": {
			"wing": {
				"damagetype": "NormalDamage",
				"damage":   [25, 150, 200],
				"duration": 40,
				"start":    11,
				"end":      31,
				"width":    100,
				"height":   500,
			},
			"leader": {
				"hpratio":  [120, 130, 140],
			},
		},
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
		"spawninterval":  100,
		"spawncount":     2,
		"spawnoffsetX":   [-20, 20],
		"spawnoffsetY":   [0, 0],
		"decaydamage":    1,
	},
	"berserker": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           10,
		"radius":         30,
		"hp":             [1000],
		"sight":          350,
		"speed":          150,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "AntiShield",
		"attackdamage":   [330, 70, 100],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"blaster": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           10,
		"radius":         30,
		"hp":             [400],
		"sight":          400,
		"speed":          150,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Missile",
		"damagetype":    "NormalDamage",
		"attackdamage":   [150, 450, 600],
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 20,
	},
	"blastturret": {
		"type":           "Building",
		"layer":          "Normal",
		"mass":           0,
		"radius":         40,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             [750],
		"sight":          350,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Missile",
		"damagetype":    "NormalDamage",
		"attackdamage":   [300],
		"attackrange":    300,
		"damageradius":   75,
		"attackinterval": 16,
		"preattackdelay": 0,
		"bulletlifetime": 15,
		"decaydamage":    2,
	},
	"cannon": {
		"type":           "Building",
		"layer":          "Normal",
		"mass":           0,
		"radius":         30,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             [450],
		"sight":          350,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Bullet",
		"damagetype":    "NormalDamage",
		"attackdamage":   [90],
		"attackrange":    275,
		"attackinterval": 8,
		"preattackdelay": 0,
		"bulletlifetime": 5,
		"decaydamage":    1,
	},
	"champion": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           20,
		"radius":         30,
		"hp":             [600],
		"shield":         [600],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "AntiShield",
		"attackdamage":   [200, 70, 100],
		"attackrange":    40,
		"damageradius":   50,
		"attackinterval": 13,
		"preattackdelay": 5,
		"chargedelay":           20,
		"chargedmovespeed":      300,
		"chargedattackdamage":   [400, 450, 550],
		"chargedattackinterval": 7,
		"chargedattackpredelay": 4,
	},
	"drillram": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           20,
		"radius":         30,
		"hp":             [1200],
		"sight":          350,
		"speed":          200,	#pixels per second
		"targettypes":    ["Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "NormalDamage",
		"attackdamage":   [30, 60, 90],
		"attackrange":    40,
		"attackinterval": 2,
		"preattackdelay": 0,
	},
	"enforcer": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           20,
		"radius":         40,
		"hp":             [1100],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "NormalDamage",
		"attackdamage":   [140, 70, 100],
		"attackrange":    40,
		"attackradius":   80,
		"attackinterval": 15,
		"preattackdelay": 1,
	},
	"felhound": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         15,
		"hp":             [50],
		"shield":         [100],
		"sight":          350,
		"speed":          200,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "AntiShield",
		"attackdamage":   [36, 60, 90],
		"attackrange":    30,
		"attackinterval": 30,
		"preattackdelay": 10,
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
		"attacktype":    "Melee",
		"damagetype":    "AntiShield",
		"attackdamage":   [75, 70, 100],
		"attackrange":    40,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"frost": {
		"mass":           0,
		"radius":         70,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Bullet",
		"damagetype":    "NormalDamage",
		"attackdamage":   [100],
		"attackrange":    350,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 2,
		"skill": {
			"wing": {
				"radius":       150,
				"castduration": 30,
				"precastdelay": 14,
			},
			"leader": {
				"slowduration": [20],
			},
		},
	},
	"gargoyle": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         25,
		"hp":             [100],
		"shield":         [150],
		"sight":          350,
		"speed":          150,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "NormalDamage",
		"attackdamage":   [50, 60, 90],
		"attackrange":    100,
		"attackinterval": 10,
		"preattackdelay": 5,
	},
	"gargoyleking": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         35,
		"hp":             [200],
		"shield":         [300],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "NormalDamage",
		"attackdamage":   [200, 60, 90],
		"attackrange":    100,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"giant": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           60,
		"radius":         60,
		"hp":             [4500],
		"sight":          350,
		"speed":          75,	#pixels per second
		"targettypes":    ["Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "NormalDamage",
		"attackdamage":   [50, 60, 90],
		"attackrange":    40,
		"attackinterval": 2,
		"preattackdelay": 0,
	},
	"ironcoffin": {
		"mass":           0,
		"radius":         110,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Missile",
		"damagetype":    "NormalDamage",
		"attackdamage":   [75],
		"attackrange":    350,
		"attackinterval": 15,
		"preattackdelay": 0,
		"bulletlifetime": 15,
		"skill": {
			"wing": {
				"name":         "sentryshelter",
				"unit":         "sentryshelter",
				"castduration": 50,
				"precastdelay": 20,
			},
			"leader": {
				"name":    "gathersentry",
				"unit":    "sentry",
				"perstep": 300,
			},
		},
	},
	"jouster": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           20,
		"radius":         30,
		"hp":             [1500],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "AntiShield",
		"attackdamage":   [280, 70, 100],
		"attackrange":    40,
		"attackinterval": 14,
		"preattackdelay": 5,
		"chargedelay":           20,
		"chargedmovespeed":      300,
		"chargedattackdamage":   [500, 450, 550],
		"chargedattackinterval": 6,
		"chargedattackpredelay": 3,
	},
	"judge": {
		"mass":           0,
		"radius":         85,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Bullet",
		"damagetype":    "NormalDamage",
		"attackdamage":   [100],
		"attackrange":    375,
		"attackinterval": 20,
		"preattackdelay": 1,
		"bulletlifetime": 2,
		"skill": {
			"wing": {
				"name":             "bulletrain",
				"damagetype":       "NormalDamage",
				"damage":           [115, 400, 500],
				"radius":           200,
				"castduration":     20,
				"precastdelay":     10,
			},
			"leader": {
				"name":             "morerange",
				"attackrangeratio": [120, 130, 140],
			},
		},
	},
	"lancer": {
		"mass":           0,
		"radius":         105,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Missile",
		"damagetype":    "NormalDamage",
		"attackdamage":   [110],
		"attackrange":    350,
		"attackinterval": 22,
		"preattackdelay": 0,
		"bulletlifetime": 22,
		"skill": {
			"wing": {
				"name":           "napalm",
				"castduration":   30,
				"precastdelay":   15,
				"damagetype":     "NormalDamage",
				"damageduration": 80,
				"damage":         60,
				"width":          200,
				"height":         400,
			},
			"leader": {
				"name":           "deathcarpet",
				"duration":       600,
				"damagetype":     "NormalDamage",
				"damage":         60,
				"count":          2,
				"posX":           [225, 775], # pos based on blue side
				"posY":           [850, 850],
				"width":          75,
				"height":         50,
			},
		},
	},
	"legion": {
		"mass":           0,
		"radius":         70,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Bullet",
		"damagetype":    "NormalDamage",
		"attackdamage":   [10],
		"attackrange":    350,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"skill": {
			"wing": {
				"name":         "fireball",
				"damagetype":   "NormalDamage",
				"damage":       [325, 400, 500],
				"radius":       125,
				"castduration": 30,
				"precastdelay": 15,
			},
			"leader": {
				"name":              "moredamage",
				"attackdamageratio": [110, 130, 140],
			},
		},
	},
	"nagmash": {
		"mass":           0,
		"radius":         105,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Laser",
		"damagetype":    "NormalDamage",
		"attackdamage":   [5],
		"attackrange":    350,
		"attackinterval": 1,
		"skill": {
			"wing": {
				"name":         "unload",
				"unit":         "footman",
				"count":        4,
				"offsetX":      [-30, 30, -30, 30],
				"offsetY":      [-30, -30, 30, 30],
				"castduration": 50,
				"precastdelay": 18,
			},
			"leader": {
				"name":         "gatherfootman",
				"unit":         "footman",
				"count":        4,
				"offsetX":      [-30, 30, -30, 30],
				"offsetY":      [-30, -30, 30, 30],
				"perstep":      300,
			},
		},
	},
	"ogre": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           60,
		"radius":         35,
		"hp":             [3800],
		"sight":          350,
		"speed":          75,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "AntiShield",
		"attackdamage":   [600, 70, 100],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"panzerkunstler": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           30,
		"radius":         30,
		"hp":             [1600],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "NormalDamage",
		"attackdamage":   [250, 70, 100],
		"attackrange":    70,
		"attackinterval": 30,
		"preattackdelay": 15,
		"powerattackdamage":    [100, 200, 300],
		"powerattackinterval":  50,
		"powerattackpredelay":  33,
		"powerattackfrequency": 3,
		"powerattackradius":    300,
		"powerattackforce":     8000,
	},
	"pixie": {
		"type":           "Troop",
		"layer":          "Ether",
		"mass":           6,
		"radius":         15,
		"hp":             [40],
		"sight":          350,
		"speed":          150,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "NormalDamage",
		"attackdamage":   [60, 70, 100],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 4,
	},
	"pixiegeode": {
		"type":          "Building",
		"layer":         "Normal",
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            [450],
		"spawn":         "pixie",
		"damagetype":    "NormalDamage",
		"spawninterval": 29,
		"spawncount":    1,
		"spawnoffsetX":  [0],
		"spawnoffsetY":  [0],
		"decaydamage":   1,
	},
	"pixieking": {
		"mass":           0,
		"radius":         110,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Bullet",
		"damagetype":    "NormalDamage",
		"attackdamage":   [50],
		"attackrange":    350,
		"attackinterval": 10,
		"preattackdelay": 1,
		"bulletlifetime": 8,
		"skill": {
			"wing": {
				"name":         "pixiegeode",
				"unit":         "pixiegeode",
				"castduration": 50,
				"precastdelay": 20,
			},
			"leader": {
				"name":    "pixiemarch",
				"unit":    "pixie",
				"perstep": 300,
				"count":   8,
				"offsetX": [-105, -75, -45, -15, 15, 45, 75, 105],
				"offsetY": [0, 0, 0, 0, 0, 0, 0, 0],
			},
		},
	},
	"psabu": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           60,
		"radius":         40,
		"hp":             [500],
		"shield":         [1000],
		"sight":          350,
		"speed":          100,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "NormalDamage",
		"attackdamage":   [250, 60, 90],
		"attackrange":    75,
		"attackinterval": 50,
		"attackradius":   120,
		"preattackdelay": 28,
		"absorbforce":    10000,
		"absorbdamage":   5,
		"absorbradius":   350,
	},
	"sentry": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         20,
		"hp":             [90],
		"sight":          350,
		"speed":          200,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Bullet",
		"damagetype":    "NormalDamage",
		"attackdamage":   [40, 60, 90],
		"attackrange":    250,
		"attackinterval": 13,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"sentryshelter": {
		"type":          "Building",
		"layer":         "Normal",
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            [735],
		"spawn":         "sentry",
		"spawninterval": 50,
		"spawncount":    1,
		"spawnoffsetX":  [0],
		"spawnoffsetY":  [0],
		"decaydamage":   1,
	},
	"shadowvision": {
		"type":           "Troop",
		"layer":          "Ether",
		"mass":           30,
		"radius":         35,
		"hp":             [300],
		"shield":         600,
		"sight":          400,
		"speed":          150,
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Missile",
		"damagetype":    "NormalDamage",
		"attackdamage":   [100, 450, 600],
		"attackrange":    175,
		"damageradius":   75,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 20,
	},
	"starfire": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           20,
		"radius":         30,
		"hp":             [550],
		"sight":          350,
		"speed":          100,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Bullet",
		"damagetype":    "NormalDamage",
		"attackdamage":   [200, 60, 90],
		"attackrange":    300,
		"attackinterval": 11,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"tombstone": {
		"mass":           0,
		"radius":         110,
		"type":           "Knight",
		"layer":          "Normal",
		"hp":             [2400],
		"sight":          350,
		"speed":          300,
		"targettypes":    ["Troop"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Laser",
		"damagetype":    "NormalDamage",
		"attackdamage":   [5],
		"attackrange":    350,
		"attackinterval": 1,
		"skill": {
			"wing": {
				"name":         "barrack",
				"unit":         "barrack",
				"castduration": 50,
				"precastdelay": 20,
			},
			"leader": {
				"name":         "lemming",
				"unit":         "footman",
				"count":        1,
				"offsetX":      150,
				"perdeaths":    4,
			},
		},
	},
	"trainee": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           6,
		"radius":         20,
		"hp":             [100],
		"sight":          350,
		"speed":          200,	#pixels per second
		"targettypes":    ["Troop", "Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "NormalDamage",
		"attackdamage":   [48, 70, 100],
		"attackrange":    40,
		"attackinterval": 12,
		"preattackdelay": 5,
	},
	"wasp": {
		"type":           "Troop",
		"layer":          "Normal",
		"mass":           40,
		"radius":         25,
		"hp":             [1000],
		"shield":         [800],
		"sight":          300,
		"speed":          100,	#pixels per second
		"targettypes":    ["Building", "Knight"],
		"targetlayers":   ["Normal"],
		"attacktype":    "Melee",
		"damagetype":    "NormalDamage",
		"attackdamage":   [600, 60, 90],
		"attackrange":    75,
		"attackinterval": 30,
		"preattackdelay": 7,
		"destroydamage":  [600],
		"destroyradius":  150,
	},
}