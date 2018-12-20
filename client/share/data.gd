extends Node

const StepPerSec = 10
const PlayTime = 180 * StepPerSec
const OverTime = 60 * StepPerSec
const EnergyBoostAfter = 120 * StepPerSec

const TileSizeInPixel = 50

const LevelMax = 12
const StatMultiplier = 110

const ShieldRegenPerStep = 2
const HoverKnightTileOffsetX = 2
const SlowPercent = 50

# CardRarity
const Common = "Common"
const Rare = "Rare"
const Epic = "Epic"
const Legendary = "Legendary"

# CardType
const KnightCard = "KnightCard"
const SquireCard = "SquireCard"

# KnightSide
const Left = "Left"
const Right = "Right"
const Center = "Center"

# UnitType
const Knight = "Knight"
const Squire = "Squire"
const Building = "Building"

# UnitLayer
const Normal = "Normal"
const Ether = "Ether"
const Casting = "Casting"

# DamageType
const NormalDamage = "NormalDamage"
const AntiShield = "AntiShield"
const Decay = "Decay"

# AttackType
const Melee = "Melee"
const Bullet = "Bullet"
const Missile = "Missile"
const Laser = "Laser"
const Bombing = "Bombing"

func NewCard(card):
	var info = cards[card.Name]
	return {
		"Name": card.Name,
		"Type": info.Type,
		"Cost": info.Cost,
		"Unit": info.get("Unit", ""),
		"Count": info.get("Count", 0),
		"OffsetX": info.get("OffsetX"),
		"OffsetY": info.get("OffsetY"),
		"Rarity": info.Rarity,
		"Level": card.Level,
		"Holding": card.get("Holding", 0),
		"Side": card.get("Side", ""),
	}
	
func CardTileNum(card):
	var nx = 1
	var ny = 1
	if card.Type == KnightCard:
		var skill = units[card.Name]["skill"]["wing"]
		if skill.has("unit"):
			var name = skill["unit"]
			if units[name]["type"] == Building:
				nx = units[name]["tilenumx"]
				ny = units[name]["tilenumy"]
	return [nx, ny]

func CardIsSpell(card):
	var nx = 1
	var ny = 1
	if card.Type == KnightCard:
		var skill = units[card.Name]["skill"]["wing"]
		if skill.has("unit"):
			var name = skill["unit"]
			if units[name]["type"] == Building:
				return false
			else:
				return true
		else:
			return true
	else:
		return false
	
var cards = {
# units
	"archengineer": {
		"Type":    KnightCard,
		"Cost":    5000,
		"Unit":    "archengineer",
		"Rarity":  Rare,
	},
	"archers": {
		"Type":    SquireCard,
		"Cost":    3000,
		"Unit":    "archer",
		"Count":   2,
		"OffsetX": [-40, 40],
		"OffsetY": [0, 0],
		"Rarity":  Common,
	},
	"archmage": {
		"Type":    SquireCard,
		"Cost":    5000,
		"Unit":    "archmage",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Rare,
	},
	"archsapper": {
		"Type":    KnightCard,
		"Cost":    3000,
		"Unit":    "archsapper",
		"Rarity":  Common,
	},
	"astra": {
		"Type":    KnightCard,
		"Cost":    4000,
		"Unit":    "astra",
		"Rarity":  Legendary,
	},
	"azero": {
		"Type":    SquireCard,
		"Cost":    3000,
		"Unit":    "azero",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Legendary,
	},
	"berserker": {
		"Type":    SquireCard,
		"Cost":    4000,
		"Unit":    "berserker",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Rare,
	},
	"blaster": {
		"Type":    SquireCard,
		"Cost": 3000,
		"Unit": "blaster",
		"Count": 1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Common,
	},
	"buran": {
		"Type":    KnightCard,
		"Cost":    5000,
		"Unit":    "buran",
		"Rarity":  Rare,
	},
	"champion": {
		"Type":    SquireCard,
		"Cost":    4000,
		"Unit":    "champion",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Epic,
	},
	"drillram": {
		"Type":    SquireCard,
		"Cost": 4000,
		"Unit": "drillram",
		"Count": 1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Rare,
	},
	"enforcer": {
		"Type":    SquireCard,
		"Cost":    4000,
		"Unit":    "enforcer",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Rare,
	},
	"felhound": {
		"Type":    SquireCard,
		"Cost":    5000,
		"Unit":    "felhound",
		"Count":   2,
		"OffsetX": [ -40, 40],
		"OffsetY": [0, 0],
		"Rarity":  Common,
	},
	"footmans": {
		"Type":    SquireCard,
		"Cost":    5000,
		"Unit":    "footman",
		"Count":   4,
		"OffsetX": [-30, 30, -30, 30],
		"OffsetY": [-30, -30, 30, 30],
		"Rarity":  Common,
	},
	"frost": {
		"Type":    KnightCard,
		"Cost":    4000,
		"Unit":    "frost",
		"Rarity":  Epic,
	},
	"gargoyles": {
		"Type":    SquireCard,
		"Cost":    3000,
		"Unit":    "gargoyle",
		"Count":   3,
		"OffsetX": [-20, 20, 0],
		"OffsetY": [20, 20, 0],
		"Rarity":  Common,
	},
	"gargoylehorde": {
		"Type":    SquireCard,
		"Cost":    5000,
		"Unit":    "gargoyle",
		"Count":   6,
		"OffsetX": [-40, 0, 40, -40, 0, 40],
		"OffsetY": [-20, -20, -20, 20, 20, 20],
		"Rarity":  Common,
	},
	"gargoyleking": {
		"Type":    SquireCard,
		"Cost":    3000,
		"Unit":    "gargoyleking",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Rare,
	},
	"giant": {
		"Type":    SquireCard,
		"Cost": 5000,
		"Unit": "giant",
		"Count": 1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Rare,
	},
	"heavymissile": {
		"Type":    SquireCard,
		"Cost":    3000,
		"Unit":    "heavymissile",
		"Count":   3,
		"OffsetX": [-30, 30, 0],
		"OffsetY": [30, 30, 0],
		"Rarity":  Rare,
	},
	"ironcoffin": {
		"Type":    KnightCard,
		"Cost":    5000,
		"Unit":    "ironcoffin",
		"Rarity":  Rare,
	},
	"jouster": {
		"Type":    SquireCard,
		"Cost":    5000,
		"Unit":    "jouster",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Epic,
	},
	"judge": {
		"Type":    KnightCard,
		"Cost":   3000,
		"Unit":    "judge",
		"Rarity":  Common,
	},
	"lancer": {
		"Type":    KnightCard,
		"Cost":    4000,
		"Unit":    "lancer",
		"Rarity":  Epic,
	},
	"legion": {
		"Type":    KnightCard,
		"Cost":    4000,
		"Unit":    "legion",
		"Rarity":  Rare,
	},
	"micromissile": {
		"Type":    SquireCard,
		"Cost":    1000,
		"Unit":   "micromissile",
		"Count":   12,
		"OffsetX": [20, 60, -20, -60, 20, 60, -20, -60, 20, 60, -20, -60],
		"OffsetY": [-40, -40, -40, -40, 0, 0, 0, 0, 40, 40, 40, 40],
		"Rarity":  Common,
	},
	"nagmash": {
		"Type":    KnightCard,
		"Cost":    4000,
		"Unit":   "nagmash",
		"Rarity":  Epic,
	},
	"nukemissile": {
		"Type":    SquireCard,
		"Cost": 5000,
		"Unit": "nukemissile",
		"Count": 1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Epic,
	},
	"ogre": {
		"Type":    SquireCard,
		"Cost":    7000,
		"Unit":    "ogre",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Epic,
	},
	"panzerkunstler": {
		"Type":    SquireCard,
		"Cost":    5000,
		"Unit":    "panzerkunstler",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Epic,
	},
	"pixie": {
		"Type":    SquireCard,
		"Cost":    1000,
		"Unit":    "pixie",
		"Count":   3,
		"OffsetX": [-30, 30, 0],
		"OffsetY": [30, 30, 0],
		"Rarity":  Rare,
	},
	"pixieking": {
		"Type":    KnightCard,
		"Cost":    3000,
		"Unit":    "pixieking",
		"Rarity":  Rare,
	},
	"psabu": {
		"Type":    SquireCard,
		"Cost":    7000,
		"Unit":    "psabu",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Legendary,
	},
	"sentry": {
		"Type":    SquireCard,
		"Cost":    2000,
		"Unit":    "sentry",
		"Count":   3,
		"OffsetX": [-30, 30, 0],
		"OffsetY": [30, 30, 0],
		"Rarity":  Common,
	},
	"shadowvision": {
		"Type":    SquireCard,
		"Cost":    4000,
		"Unit":    "shadowvision",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Epic,
	},
	"starfire": {
		"Type":    SquireCard,
		"Cost":    4000,
		"Unit":    "starfire",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Rare,
	},
	"threestarfires": {
		"Type":    SquireCard,
		"Cost":    9000,
		"Unit":    "starfire",
		"Count":   3,
		"OffsetX": [-50, 50, 0],
		"OffsetY": [50, 50, 0],
		"Rarity":  Rare,
	},
	"tombstone": {
		"Type":    KnightCard,
		"Cost":    6000,
		"Unit":    "tombstone",
		"Rarity":  Rare,
	},
	"trainee": {
		"Type":    SquireCard,
		"Cost":    2000,
		"Unit":    "trainee",
		"Count":   3,
		"OffsetX": [-30, 30, 0],
		"OffsetY": [30, 30, 0],
		"Rarity":  Rare,
	},
	"voidcreeper": {
		"Type":    SquireCard,
		"Cost":    5000,
		"Unit":    "voidcreeper",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Epic,
	},
	"wasp": {
		"Type":    SquireCard,
		"Cost":    5000,
		"Unit":    "wasp",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Epic,
	},
}

var units = {
	"archengineer": {
		"mass":           0,
		"radius":         75,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
		"attackdamage":   [100],
		"attackrange":    350,
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
				"arearatio":    200,
			},
		},
	},
	"archer": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             [180],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
		"attackdamage":   [70],
		"attackrange":    250,
		"attackinterval": 12,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"archmage": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         42,
		"hp":             [500],
		"sight":          275,
		"speed":          150,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
		"attackdamage":   [400, 450, 600],
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 17,
		"preattackdelay": 11,
		"bulletlifetime": 4,
	},
	"archsapper": {
		"mass":           0,
		"radius":         75,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
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
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Laser,
		"damagetype":    NormalDamage,
		"attackdamage":   [5],
		"attackrange":    350,
		"attackinterval": 1,
		"skill": {
			"wing": {
				"damagetype": NormalDamage,
				"damage":   [25, 150, 200],
				"duration": 40,
				"start":    11,
				"end":      31,
				"width":    50,
				"height":   250,
			},
			"leader": {
				"hpratio":  [130, 140, 150],
			},
		},
	},
	"azero": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         50,
		"hp":             [1000],
		"sight":          275,
		"speed":          150,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
		"attackdamage":   [200, 450, 600],
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 12,
		"preattackdelay": 7,
		"bulletlifetime": 4,
		"slowduration":   80,
	},
	"barrack": {
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         60,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             [1800],
		"spawn":          "footman",
		"spawninterval":  80,
		"spawncount":     2,
		"spawnoffsetX":   [-20, 20],
		"spawnoffsetY":   [0, 0],
		"decaydamage":    3,
	},
	"beholder": {
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         30,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             [1500],
		"sight":          275,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Laser,
		"damagetype":    NormalDamage,
		"attackdamage":   [5],
		"attackrange":    275,
		"attackinterval": 1,
		"decaydamage":    2,
	},
	"berserker": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           10,
		"radius":         30,
		"hp":             [900],
		"sight":          275,
		"speed":          150,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    AntiShield,
		"attackdamage":   [330, 70, 100],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"blaster": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           10,
		"radius":         30,
		"hp":             [400],
		"sight":          275,
		"speed":          150,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Missile,
		"damagetype":    NormalDamage,
		"attackdamage":   [150, 450, 600],
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 20,
	},
	"blastturret": {
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         40,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             [1500],
		"sight":          300,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Missile,
		"damagetype":    NormalDamage,
		"attackdamage":   [300],
		"attackrange":    300,
		"damageradius":   100,
		"attackinterval": 16,
		"preattackdelay": 0,
		"bulletlifetime": 15,
		"decaydamage":    3,
	},
	"buran": {
		"mass":           0,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Laser,
		"damagetype":    NormalDamage,
		"attackdamage":   [5],
		"attackrange":    350,
		"attackinterval": 1,
		"skill": {
			"wing": {
				"name":         "beholder",
				"unit":         "beholder",
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
	"cannon": {
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         30,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             [800],
		"sight":          275,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    AntiShield,
		"attackdamage":   [120],
		"attackrange":    275,
		"attackinterval": 8,
		"preattackdelay": 0,
		"bulletlifetime": 5,
		"decaydamage":    2,
	},
	"champion": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         30,
		"hp":             [400],
		"shield":         [800],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    AntiShield,
		"attackdamage":   [90, 70, 100],
		"attackrange":    40,
		"damageradius":   50,
		"attackinterval": 13,
		"preattackdelay": 5,
		"chargedelay":           20,
		"chargedmovespeed":      300,
		"chargedattackdamage":   [180, 450, 550],
		"chargedattackinterval": 7,
		"chargedattackpredelay": 4,
	},
	"drillram": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         30,
		"hp":             [1200],
		"sight":          475,
		"speed":          200,	#pixels per second
		"targettypes":    [Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [30, 60, 90],
		"attackrange":    40,
		"attackinterval": 2,
		"preattackdelay": 0,
	},
	"enforcer": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         40,
		"hp":             [1000],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [130, 70, 100],
		"attackrange":    40,
		"attackradius":   80,
		"attackinterval": 15,
		"preattackdelay": 1,
	},
	"felhound": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           10,
		"radius":         35,
		"hp":             [300],
		"shield":         [300],
		"sight":          275,
		"speed":          200,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    AntiShield,
		"attackdamage":   [210, 60, 90],
		"attackrange":    30,
		"attackinterval": 30,
		"preattackdelay": 10,
	},
	"footman": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             [300],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    AntiShield,
		"attackdamage":   [75, 70, 100],
		"attackrange":    40,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"frost": {
		"mass":           0,
		"radius":         70,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
		"attackdamage":   [100],
		"attackrange":    350,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 2,
		"skill": {
			"wing": {
				"radius":       150,
				"castduration": 30,
				"freezeduration": 50,
				"precastdelay": 20,
			},
			"leader": {
				"slowduration": [30],
			},
		},
	},
	"gargoyle": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             [100],
		"shield":         [200],
		"sight":          275,
		"speed":          150,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [40, 60, 90],
		"attackrange":    100,
		"attackinterval": 10,
		"preattackdelay": 5,
	},
	"gargoyleking": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         35,
		"hp":             [200],
		"shield":         [400],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [200, 60, 90],
		"attackrange":    100,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"giant": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           60,
		"radius":         60,
		"hp":             [2700],
		"sight":          375,
		"speed":          75,	#pixels per second
		"targettypes":    [Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [45, 60, 90],
		"attackrange":    40,
		"attackinterval": 2,
		"preattackdelay": 0,
	},
	"heavymissile": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           10,
		"radius":         30,
		"hp":             [100],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [1, 70, 100],
		"attackrange":    35,
		"attackinterval": 0,
		"preattackdelay": 0,
		"destroydamage":  [300],
		"destroyradius":  75,
	},
	"ironcoffin": {
		"mass":           0,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Missile,
		"damagetype":    NormalDamage,
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
				"perstep": 100,
			},
		},
	},
	"jouster": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         30,
		"hp":             [1500],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    AntiShield,
		"attackdamage":   [220, 70, 100],
		"attackrange":    40,
		"attackinterval": 14,
		"preattackdelay": 5,
		"chargedelay":           20,
		"chargedmovespeed":      300,
		"chargedattackdamage":   [450, 450, 550],
		"chargedattackinterval": 6,
		"chargedattackpredelay": 3,
	},
	"judge": {
		"mass":           0,
		"radius":         85,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          400,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
		"attackdamage":   [100],
		"attackrange":    400,
		"attackinterval": 20,
		"preattackdelay": 1,
		"bulletlifetime": 2,
		"skill": {
			"wing": {
				"name":             "bulletrain",
				"damagetype":       NormalDamage,
				"damage":           [115, 400, 500],
				"radius":           200,
				"castduration":     20,
				"precastdelay":     10,
			},
			"leader": {
				"name":             "morerange",
				"attackrangeratio": [140, 150, 160],
			},
		},
	},
	"lancer": {
		"mass":           0,
		"radius":         105,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Missile,
		"damagetype":    NormalDamage,
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
				"damagetype":     NormalDamage,
				"damageduration": 80,
				"damage":         [60, 70, 80],
				"width":          200,
				"height":         400,
			},
			"leader": {
				"name":           "deathcarpet",
				"duration":       600,
				"damagetype":     NormalDamage,
				"damage":         [45, 55, 65],
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
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
		"attackdamage":   [10],
		"attackrange":    350,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"skill": {
			"wing": {
				"name":         "fireball",
				"damagetype":   NormalDamage,
				"damage":       [325, 400, 500],
				"radius":       125,
				"castduration": 30,
				"precastdelay": 15,
			},
			"leader": {
				"name":              "moredamage",
				"attackdamageratio": [130, 130, 140],
			},
		},
	},
	"micromissile": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           1,
		"radius":         30,
		"hp":             [10],
		"sight":          275,
		"speed":          400,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [1, 70, 100],
		"attackrange":    35,
		"attackinterval": 0,
		"preattackdelay": 0,
		"destroydamage":  [30],
		"destroyradius":  50,
	},
	"nagmash": {
		"mass":           0,
		"radius":         105,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Laser,
		"damagetype":    NormalDamage,
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
	"nukemissile": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           80,
		"radius":         50,
		"hp":             [2000],
		"sight":          275,
		"speed":          75,	#pixels per second
		"targettypes":    [Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [1, 70, 100],
		"attackrange":    55,
		"attackinterval": 0,
		"preattackdelay": 0,
		"destroydamage":  [800],
		"destroyradius":  100,
	},
	"ogre": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           60,
		"radius":         35,
		"hp":             [3000],
		"sight":          250,
		"speed":          75,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    AntiShield,
		"attackdamage":   [450, 70, 100],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"panzerkunstler": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           30,
		"radius":         30,
		"hp":             [1500],
		"shield":         [1000],
		"sight":          250,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [250, 70, 100],
		"attackrange":    70,
		"attackinterval": 30,
		"preattackdelay": 15,
		"powerattackdamage":    [150, 200, 300],
		"powerattackinterval":  50,
		"powerattackpredelay":  33,
		"powerattackfrequency": 3,
		"powerattackradius":    300,
		"powerattackforce":     8000,
	},
	"pixie": {
		"type":           Squire,
		"layer":          Ether,
		"mass":           6,
		"radius":         15,
		"hp":             [40],
		"sight":          275,
		"speed":          150,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [60, 70, 100],
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 4,
	},
	"pixiegeode": {
		"type":          Building,
		"layer":         Normal,
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            [430],
		"spawn":         "pixie",
		"damagetype":    NormalDamage,
		"spawninterval": 30,
		"spawncount":    1,
		"spawnoffsetX":  [0],
		"spawnoffsetY":  [0],
		"decaydamage":   1,
	},
	"pixieking": {
		"mass":           0,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
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
		"type":           Squire,
		"layer":          Normal,
		"mass":           60,
		"radius":         40,
		"hp":             [800],
		"shield":         [1000],
		"sight":          200,
		"speed":          100,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
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
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             [90],
		"sight":          275,
		"speed":          200,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
		"attackdamage":   [35, 60, 90],
		"attackrange":    250,
		"attackinterval": 13,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"sentryshelter": {
		"type":          Building,
		"layer":         Normal,
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            [1000],
		"spawn":         "sentry",
		"spawninterval": 45,
		"spawncount":    1,
		"spawnoffsetX":  [0],
		"spawnoffsetY":  [0],
		"decaydamage":   2,
	},
	"shadowvision": {
		"type":           Squire,
		"layer":          Ether,
		"mass":           30,
		"radius":         35,
		"hp":             [300],
		"shield":         [600],
		"sight":          250,
		"speed":          150,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Missile,
		"damagetype":    NormalDamage,
		"attackdamage":   [100],
		"attackrange":    175,
		"damageradius":   75,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 20,
	},
	"starfire": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         30,
		"hp":             [550],
		"sight":          300,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Bullet,
		"damagetype":    NormalDamage,
		"attackdamage":   [180],
		"attackrange":    300,
		"attackinterval": 11,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"tombstone": {
		"mass":           0,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [3400],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"attacktype":    Laser,
		"damagetype":    NormalDamage,
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
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             [100],
		"sight":          275,
		"speed":          200,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [48],
		"attackrange":    40,
		"attackinterval": 12,
		"preattackdelay": 5,
	},
	"voidcreeper": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           40,
		"radius":         30,
		"hp":             [1200],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    AntiShield,
		"attackdamage":   [175],
		"attackrange":    70,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"wasp": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           40,
		"radius":         25,
		"hp":             [1400],
		"shield":         [800],
		"sight":          375,
		"speed":          100,	#pixels per second
		"targettypes":    [Building, Knight],
		"targetlayers":   [Normal],
		"attacktype":    Melee,
		"damagetype":    NormalDamage,
		"attackdamage":   [600],
		"attackrange":    75,
		"attackinterval": 30,
		"preattackdelay": 7,
		"destroydamage":  [300],
		"destroyradius":  150,
	},
}

var Upgrade

func Initialize():
	for k in units:
		fillStatByLevel(k, units[k])

const levelMultipier = 110

func fillStatByLevel(key, value):
	match typeof(value):
		TYPE_DICTIONARY:
			for k in value:
				var arr = fillStatByLevel(k, value[k])
				if arr != null:
					value[k] = arr
			return null
		TYPE_ARRAY:
			match key:
				"hp", "shield", "attackdamage", "destroydamage", "chargedattackdamage", "powerattackdamage", "damage", "hpratio", "attackdamageratio", "attackrangeratio", "slowduration":
					value.resize(1)
					var baseValue = value[0]
					var multiplier = StatMultiplier
					for i in range(LevelMax):
						value.append(baseValue * multiplier / 100)
						multiplier = multiplier * StatMultiplier / 100
					return value
				_:
					return null
		_:
			return null