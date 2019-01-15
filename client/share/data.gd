extends Node

const StepPerSec = 10
const PlayTime = 180 * StepPerSec
const OverTime = 60 * StepPerSec
const EnergyBoostAfter = 120 * StepPerSec

const TileSizeInPixel = 50

const LevelMax = 13
const StatMultiplier = 110

const DecreasedDamageRatioOnKnightBuilding = 35
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
const AntiShield = 1 << 0
const DecreaseOnKnight = 1 << 1
const Melee = 1 << 2
const Siege = 1 << 3
const Death = 1 << 4
const Decay = 1 << 5
const Skill = 1 << 6
const Bullet = 1 << 7
const Missile = 1 << 8
const Laser = 1 << 9

func DamageTypeIs(damageType, bits):
	return damageType & bits != 0

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
	"absorber": {
		"Type":    SquireCard,
		"Cost":    5000,
		"Unit":    "absorber",
		"Count":   1,
		"OffsetX": [0],
		"OffsetY": [0],
		"Rarity":  Legendary,
	},
	"archengineer": {
		"Type":    KnightCard,
		"Cost":    4000,
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
		"Cost":    2000,
		"Unit":    "archsapper",
		"Rarity":  Common,
	},
	"astra": {
		"Type":    KnightCard,
		"Cost":    3000,
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
		"Cost":    3000,
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
		"Cost":    4000,
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
		"Cost":    2000,
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
	"gargoylesquad": {
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
		"Cost":    4000,
		"Unit":    "heavymissile",
		"Count":   3,
		"OffsetX": [-30, 30, 0],
		"OffsetY": [30, 30, 0],
		"Rarity":  Rare,
	},
	"ironcoffin": {
		"Type":    KnightCard,
		"Cost":    4000,
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
		"Cost":   2000,
		"Unit":    "judge",
		"Rarity":  Common,
	},
	"lancer": {
		"Type":    KnightCard,
		"Cost":    3000,
		"Unit":    "lancer",
		"Rarity":  Epic,
	},
	"legion": {
		"Type":    KnightCard,
		"Cost":    3000,
		"Unit":    "legion",
		"Rarity":  Rare,
	},
	"micromissile": {
		"Type":    SquireCard,
		"Cost":    3000,
		"Unit":   "micromissile",
		"Count":   12,
		"OffsetX": [20, 60, -20, -60, 20, 60, -20, -60, 20, 60, -20, -60],
		"OffsetY": [-40, -40, -40, -40, 0, 0, 0, 0, 40, 40, 40, 40],
		"Rarity":  Common,
	},
	"nagmash": {
		"Type":    KnightCard,
		"Cost":    3000,
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
		"Cost":    2000,
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
		"Cost":    5000,
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
	"valkyrie": {
		"Type":    KnightCard,
		"Cost":    1000,
		"Unit":    "valkyrie",
		"Rarity":  Common,
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
	"absorber": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           30,
		"radius":         30,
		"hp":             [1850],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Melee,
		"attackdamage":   [250],
		"attackrange":    80,
		"attackradius":   100,
		"attackinterval": 20,
		"preattackdelay": 9,
		"absorbratio":    50,
	},
	"archengineer": {
		"mass":           0,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4600],
		"sight":          350,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   [140],
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
				"name":               "louder",
				"expanddamageradius": [3],
			},
		},
	},
	"archer": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           9,
		"radius":         30,
		"hp":             [180],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Bullet,
		"attackdamage":   [70],
		"attackrange":    250,
		"attackinterval": 12,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"archmage": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           42,
		"radius":         42,
		"hp":             [550],
		"sight":          275,
		"speed":          150,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Bullet,
		"attackdamage":   [280],
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 17,
		"preattackdelay": 11,
		"bulletlifetime": 4,
	},
	"archsapper": {
		"mass":           0,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4700],
		"sight":          350,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   [105],
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
				"hpratio":      [300],
			},
		},
	},
	"astra": {
		"mass":           0,
		"radius":         70,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4400],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Laser,
		"attackdamage":   [28],
		"attackrange":    350,
		"attackinterval": 4,
		"skill": {
			"wing": {
				"name":       "megalaser",
				"damagetype": DecreaseOnKnight | Skill,
				"damage":     [50],
				"duration":   40,
				"start":      11,
				"end":        31,
				"width":      120,
				"height":     520,
			},
			"leader": {
				"name":    "reinforce",
				"hpratio": [110],
			},
		},
	},
	"azero": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           32,
		"radius":         32,
		"hp":             [650],
		"sight":          275,
		"speed":          150,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Bullet,
		"attackdamage":   [150],
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
		"type":              Building,
		"layer":             Normal,
		"mass":              0,
		"radius":            30,
		"tilenumx":          3,
		"tilenumy":          3,
		"hp":                [1500],
		"sight":             300,
		"targettypes":       [Squire, Building, Knight],
		"targetlayers":      [Normal],
		"damagetype":        Laser,
		"attackdamage":      [20],
		"attackrange":       300,
		"attackinterval":    4,
		"decaydamage":       2,
		"amplifycountlimit": 10,
	},
	"berserker": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           18,
		"radius":         30,
		"hp":             [950],
		"sight":          275,
		"speed":          150,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Melee,
		"attackdamage":   [350],
		"attackrange":    50,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"blaster": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           21,
		"radius":         35,
		"hp":             [400],
		"sight":          275,
		"speed":          150,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Missile,
		"attackdamage":   [240],
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
		"hp":             [2000],
		"sight":          300,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Missile,
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
		"radius":         95,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4500],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Laser,
		"attackdamage":   [28],
		"attackrange":    350,
		"attackinterval": 4,
		"skill": {
			"wing": {
				"name":         "beholder",
				"unit":         "beholder",
				"castduration": 50,
				"precastdelay": 20,
			},
			"leader": {
				"name":                "amplify",
				"amplifydamagepersec": [3],
				"amplifycountlimit":   10,
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
		"hp":             [1500],
		"sight":          275,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   [135],
		"attackrange":    275,
		"attackinterval": 8,
		"preattackdelay": 0,
		"bulletlifetime": 5,
		"decaydamage":    2,
	},
	"champion": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           28,
		"radius":         35,
		"hp":             [600],
		"shield":         [1800],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Melee,
		"attackdamage":   [120],
		"attackrange":    55,
		"damageradius":   50,
		"attackinterval": 13,
		"preattackdelay": 5,
		"chargedelay":           20,
		"chargedmovespeed":      300,
		"chargedattackdamagetype": AntiShield | Melee,
		"chargedattackdamage":   [240],
		"chargedattackinterval": 7,
		"chargedattackpredelay": 4,
	},
	"drillram": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           40,
		"radius":         50,
		"hp":             [1200],
		"sight":          475,
		"speed":          200,	#pixels per second
		"targettypes":    [Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Melee | Siege,
		"attackdamage":   [40],
		"attackrange":    70,
		"attackinterval": 2,
		"preattackdelay": 0,
	},
	"enforcer": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           32,
		"radius":         40,
		"hp":             [1350],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Melee,
		"attackdamage":   [190],
		"attackrange":    60,
		"attackradius":   80,
		"attackinterval": 15,
		"preattackdelay": 1,
	},
	"felhound": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         40,
		"hp":             [630],
		"shield":         [1890],
		"sight":          275,
		"speed":          200,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Melee,
		"attackdamage":   [330],
		"attackrange":    60,
		"attackinterval": 30,
		"preattackdelay": 10,
	},
	"footman": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             [400],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Melee,
		"attackdamage":   [75],
		"attackrange":    45,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"frost": {
		"mass":           0,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4500],
		"sight":          350,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   [140],
		"attackrange":    350,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 2,
		"skill": {
			"wing": {
				"name":           "freeze",
				"radius":         200,
				"castduration":   30,
				"freezeduration": 50,
				"precastdelay":   20,
			},
			"leader": {
				"name":         "frozenbullet",
				"slowduration": [30],
			},
		},
	},
	"gargoyle": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           5,
		"radius":         27,
		"hp":             [180],
		"shield":         [540],
		"sight":          275,
		"speed":          150,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Melee,
		"attackdamage":   [40],
		"attackrange":    100,
		"attackinterval": 10,
		"preattackdelay": 5,
	},
	"gargoyleking": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           22,
		"radius":         37,
		"hp":             [750],
		"shield":         [2250],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Melee,
		"attackdamage":   [200],
		"attackrange":    100,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"giant": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           50,
		"radius":         50,
		"hp":             [2700],
		"sight":          375,
		"speed":          75,	#pixels per second
		"targettypes":    [Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Melee | Siege,
		"attackdamage":   [50],
		"attackrange":    70,
		"attackinterval": 2,
		"preattackdelay": 0,
	},
	"heavymissile": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           3,
		"radius":         12,
		"hp":             [350],
		"sight":          275,
		"speed":          150,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     DecreaseOnKnight | Melee | Death,
		"attackdamage":   [300],
		"attackrange":    32,
		"preattackdelay": 3,
		"attackradius":   105,
	},
	"ironcoffin": {
		"mass":           0,
		"radius":         65,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4600],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Missile,
		"attackdamage":   [140],
		"attackrange":    350,
		"attackinterval": 20,
		"preattackdelay": 13,
		"bulletlifetime": 20,
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
		"mass":           35,
		"radius":         35,
		"hp":             [1650],
		"sight":          275,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Melee,
		"attackdamage":   [270],
		"attackrange":    55,
		"attackinterval": 14,
		"preattackdelay": 5,
		"chargedelay":            20,
		"chargedmovespeed":       300,
		"chargedattackdamagetype": AntiShield | Melee,
		"chargedattackdamage":    [520],
		"chargedattackinterval":  6,
		"chargedattackpredelay":  3,
	},
	"judge": {
		"mass":           0,
		"radius":         60,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4700],
		"sight":          400,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   [140],
		"attackrange":    400,
		"attackinterval": 20,
		"preattackdelay": 1,
		"bulletlifetime": 2,
		"skill": {
			"wing": {
				"name":             "bulletrain",
				"damagetype":       DecreaseOnKnight | Skill,
				"damage":           [350],
				"radius":           200,
				"castduration":     20,
				"precastdelay":     10,
			},
			"leader": {
				"name":             "morerange",
				"attackrangeratio": [110],
			},
		},
	},
	"lancer": {
		"mass":           0,
		"radius":         85,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4500],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Missile,
		"attackdamage":   [154],
		"attackrange":    350,
		"attackinterval": 22,
		"preattackdelay": 17,
		"bulletlifetime": 22,
		"skill": {
			"wing": {
				"name":           "napalm",
				"castduration":   30,
				"precastdelay":   15,
				"damagetype":     DecreaseOnKnight | Skill,
				"damageduration": 80,
				"damage":         [105],
				"width":          200,
				"height":         400,
			},
			"leader": {
				"name":           "deathcarpet",
				"duration":       600,
				"damagetype":     DecreaseOnKnight | Skill,
				"damage":         [150],
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
		"radius":         55,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4600],
		"sight":          350,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   [14],
		"attackrange":    350,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"skill": {
			"wing": {
				"name":         "fireball",
				"damagetype":   DecreaseOnKnight | Skill,
				"damage":       [720],
				"radius":       125,
				"castduration": 30,
				"precastdelay": 15,
			},
			"leader": {
				"name":              "moredamage",
				"attackdamageratio": [110],
			},
		},
	},
	"micromissile": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           1,
		"radius":         12,
		"hp":             [60],
		"sight":          275,
		"speed":          300,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     DecreaseOnKnight | Melee | Death,
		"attackdamage":   [95],
		"attackrange":    22,
		"attackradius":   80,
		"preattackdelay": 3,
	},
	"nagmash": {
		"mass":           0,
		"radius":         85,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4500],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Laser,
		"attackdamage":   [28],
		"attackrange":    350,
		"attackinterval": 4,
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
		"mass":           40,
		"radius":         40,
		"hp":             [1700],
		"sight":          275,
		"speed":          75,	#pixels per second
		"targettypes":    [Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     DecreaseOnKnight | Melee | Death,
		"attackdamage":   [1000],
		"attackrange":    60,
		"attackradius":   150,
		"preattackdelay": 3,
	},
	"ogre": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           56,
		"radius":         40,
		"hp":             [3100],
		"sight":          250,
		"speed":          75,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Melee,
		"attackdamage":   [550],
		"attackrange":    60,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"panzerkunstler": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           35,
		"radius":         35,
		"hp":             [1000],
		"shield":         [3000],
		"sight":          250,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Melee,
		"attackdamage":   [250],
		"attackrange":    55,
		"attackinterval": 30,
		"preattackdelay": 15,
		"powerattackdamagetype":   DecreaseOnKnight | Melee,
		"powerattackdamage":       [350],
		"powerattackdamageradius": 120,
		"powerattackinterval":     50,
		"powerattackpredelay":     33,
		"powerattackfrequency":    3,
		"powerattackradius":       350,
		"powerattackforce":        10000,
	},
	"pixie": {
		"type":           Squire,
		"layer":          Ether,
		"mass":           1,
		"radius":         15,
		"hp":             [40],
		"sight":          275,
		"speed":          150,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Melee,
		"attackdamage":   [60],
		"attackrange":    35,
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
		"spawninterval": 30,
		"spawncount":    1,
		"spawnoffsetX":  [0],
		"spawnoffsetY":  [0],
		"decaydamage":   1,
	},
	"pixieking": {
		"mass":           0,
		"radius":         60,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4600],
		"sight":          350,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   [70],
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
		"mass":           63,
		"radius":         45,
		"hp":             [1300],
		"shield":         [3900],
		"sight":          200,
		"speed":          100,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Melee,
		"attackdamage":   [190],
		"attackrange":    65,
		"attackinterval": 50,
		"attackradius":   120,
		"preattackdelay": 28,
		"absorbforce":        10000,
		"absorbdamagetype":   DecreaseOnKnight | Melee,
		"absorbdamage":       6,
		"absorbdamageradius": 100,
		"absorbradius":       350,
	},
	"sentry": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           2,
		"radius":         20,
		"hp":             [90],
		"sight":          275,
		"speed":          200,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Bullet,
		"attackdamage":   [35],
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
		"mass":           32,
		"radius":         40,
		"hp":             [400],
		"shield":         [1200],
		"sight":          250,
		"speed":          150,
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Missile,
		"attackdamage":   [150],
		"attackrange":    175,
		"damageradius":   75,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 20,
	},
	"starfire": {
		"type":           Squire,
		"layer":          Normal,
		"mass":           24,
		"radius":         30,
		"hp":             [550],
		"sight":          300,
		"speed":          100,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Bullet,
		"attackdamage":   [155],
		"attackrange":    300,
		"attackinterval": 11,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"tombstone": {
		"mass":           0,
		"radius":         85,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4600],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Laser,
		"attackdamage":   [28],
		"attackrange":    350,
		"attackinterval": 4,
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
		"mass":           3,
		"radius":         24,
		"hp":             [110],
		"sight":          275,
		"speed":          200,	#pixels per second
		"targettypes":    [Squire, Building, Knight],
		"targetlayers":   [Normal],
		"damagetype":     Melee,
		"attackdamage":   [48],
		"attackrange":    44,
		"attackinterval": 12,
		"preattackdelay": 5,
	},
	"valkyrie": {
		"mass":           0,
		"radius":         60,
		"type":           Knight,
		"layer":          Normal,
		"hp":             [4700],
		"sight":          350,
		"speed":          300,
		"targettypes":    [Squire],
		"targetlayers":   [Normal],
		"damagetype":     AntiShield | Missile,
		"attackdamage":   [140],
		"attackrange":    350,
		"attackinterval": 20,
		"preattackdelay": 15,
		"bulletlifetime": 20,
		"skill": {
			"wing": {
				"name":             "emp",
				"damagetype":       DecreaseOnKnight | Skill,
				"damage":           [140],
				"radius":           200,
				"castduration":     10,
				"precastdelay":     4,
			},
			"leader": {
				"name":             "morerange",
				"attackrangeratio": [140, 150, 160],
			},
		},
	},
	"voidcreeper": {
		"type":              Squire,
		"layer":             Normal,
		"mass":              45,
		"radius":            45,
		"hp":                [1750],
		"sight":             275,
		"speed":             100,	#pixels per second
		"targettypes":       [Squire, Building, Knight],
		"targetlayers":      [Normal],
		"damagetype":        AntiShield | Melee,
		"attackdamage":      [270],
		"damageradius":      50,
		"attackrange":       75,
		"attackinterval":    15,
		"preattackdelay":    5,
		"destroydamagetype": DecreaseOnKnight | Melee | Death,
		"destroydamage":     [400],
		"destroyradius":     175,
	},
	"wasp": {
		"type":              Squire,
		"layer":             Normal,
		"mass":              55,
		"radius":            55,
		"hp":                [1400],
		"shield":            [4200],
		"sight":             375,
		"speed":             100,	#pixels per second
		"targettypes":       [Building, Knight],
		"targetlayers":      [Normal],
		"damagetype":        Melee,
		"attackdamage":      [600],
		"attackrange":       75,
		"attackinterval":    30,
		"preattackdelay":    7,
		"destroydamagetype": DecreaseOnKnight | Melee | Death,
		"destroydamage":     [400],
		"destroyradius":     175,
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
				"hp", "shield",\
				"attackdamage", "destroydamage",\
				"chargedattackdamage", "powerattackdamage",\
				"damage",\
				"hpratio", "attackdamageratio", "attackrangeratio",\
				"amplifydamagepersec",\
				"expanddamageradius",\
				"slowduration":
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


var Chests = {
	"Silver": {
		"Duration":       3600 * 3,
	},
	"Gold": {
		"Duration":       3600 * 8,
	},
	"Diamond": {
		"Duration":       3600 * 12,
	},
	"D-Matter": {
		"Duration":       3600 * 12,
	},
	"E-Matter": {
		"Duration":       3600 * 12,
	},
	"Free": {
		"Duration":       3600 * 4,
	},
	"Medal": {
		"Duration": 0,
	},
}

var ChestOrder = []