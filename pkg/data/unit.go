package data

type UnitType string
type UnitTypes []UnitType

const (
	Knight   UnitType = "Knight"
	Squire   UnitType = "Squire"
	Building UnitType = "Building"
)

func (types UnitTypes) Contains(type_ UnitType) bool {
	for _, t := range types {
		if t == type_ {
			return true
		}
	}
	return false
}

type UnitLayer string
type UnitLayers []UnitLayer

const (
	Normal  UnitLayer = "Normal"
	Ether   UnitLayer = "Ether"
	Casting UnitLayer = "Casting"
)

func (layers UnitLayers) Contains(layer UnitLayer) bool {
	for _, l := range layers {
		if l == layer {
			return true
		}
	}
	return false
}

type DamageType int

const (
	AntiShield DamageType = 1 << iota
	DecreaseOnKnight
	Melee
	Siege
	Death
	Decay
	Skill
	Bullet
	Missile
	Laser
)

func (d DamageType) Is(bits DamageType) bool { return d&bits != 0 }

type Unit map[string]interface{}

var Units = map[string]Unit{
	"absorber": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           30,
		"radius":         30,
		"hp":             []int{1850},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Melee,
		"attackdamage":   []int{250},
		"attackrange":    80,
		"attackradius":   100,
		"attackinterval": 20,
		"preattackdelay": 9,
		"absorbratio":    50,
		"estimatedcost":  5000,
	},
	"archengineer": map[string]interface{}{
		"mass":           0,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4600},
		"sight":          375,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   []int{140},
		"attackrange":    375,
		"attackinterval": 20,
		"preattackdelay": 10,
		"bulletlifetime": 10,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "blastturret",
				"unit":         "blastturret",
				"castduration": 50,
				"precastdelay": 38,
			},
			"leader": map[string]interface{}{
				"name":               "louder",
				"expanddamageradius": []int{3},
			},
		},
		"estimatedcost": 0,
	},
	"archer": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           9,
		"radius":         30,
		"hp":             []int{180},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Bullet,
		"attackdamage":   []int{70},
		"attackrange":    250,
		"attackinterval": 12,
		"preattackdelay": 0,
		"bulletlifetime": 6,
		"estimatedcost":  1500,
	},
	"archmage": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           42,
		"radius":         42,
		"hp":             []int{550},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Bullet,
		"attackdamage":   []int{280},
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 17,
		"preattackdelay": 11,
		"bulletlifetime": 4,
		"estimatedcost":  5000,
	},
	"archsapper": map[string]interface{}{
		"mass":           0,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4700},
		"sight":          375,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   []int{105},
		"attackrange":    375,
		"attackinterval": 15,
		"preattackdelay": 5,
		"bulletlifetime": 7,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "cannon",
				"unit":         "cannon",
				"castduration": 50,
				"precastdelay": 39,
			},
			"leader": map[string]interface{}{
				"name":    "readycannon",
				"unit":    "cannon",
				"count":   2,
				"posX":    []int{325, 675}, // pos based on blue side
				"posY":    []int{1075, 1075},
				"hpratio": []int{300},
			},
		},
		"estimatedcost": 0,
	},
	"astra": map[string]interface{}{
		"mass":           0,
		"radius":         70,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          375,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Laser,
		"attackdamage":   []int{28},
		"attackrange":    375,
		"attackinterval": 4,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":       "megalaser",
				"damagetype": DecreaseOnKnight | Skill,
				"damage":     []int{50},
				"duration":   40,
				"start":      11,
				"end":        31,
				"width":      120,
				"height":     520,
			},
			"leader": map[string]interface{}{
				"name":    "reinforce",
				"hpratio": []int{52},
			},
		},
		"estimatedcost": 0,
	},
	"azero": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           32,
		"radius":         32,
		"hp":             []int{650},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Bullet,
		"attackdamage":   []int{150},
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 12,
		"preattackdelay": 7,
		"bulletlifetime": 4,
		"slowduration":   80,
		"estimatedcost":  3000,
	},
	"barrack": map[string]interface{}{
		"type":          Building,
		"layer":         Normal,
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            []int{1600},
		"spawn":         "footman",
		"spawninterval": 80,
		"spawncount":    2,
		"spawnoffsetX":  []int{-20, 20},
		"spawnoffsetY":  []int{0, 0},
		"decaydamage":   4,
		"estimatedcost": 0,
	},
	"beholder": map[string]interface{}{
		"type":              Building,
		"layer":             Normal,
		"mass":              0,
		"radius":            30,
		"tilenumx":          3,
		"tilenumy":          3,
		"hp":                []int{1600},
		"sight":             300,
		"targettypes":       UnitTypes{Squire, Building, Knight},
		"targetlayers":      UnitLayers{Normal},
		"damagetype":        Laser,
		"attackdamage":      []int{20},
		"attackrange":       300,
		"attackinterval":    4,
		"decaydamage":       4,
		"amplifycountlimit": 10,
		"estimatedcost":     4000,
	},
	"berserker": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           18,
		"radius":         30,
		"hp":             []int{950},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Melee,
		"attackdamage":   []int{350},
		"attackrange":    50,
		"attackinterval": 20,
		"preattackdelay": 6,
		"estimatedcost":  3000,
	},
	"blaster": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           21,
		"radius":         35,
		"hp":             []int{400},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Missile,
		"attackdamage":   []int{240},
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 20,
		"estimatedcost":  3000,
	},
	"blastturret": map[string]interface{}{
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         40,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             []int{1400},
		"sight":          300,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Missile,
		"attackdamage":   []int{300},
		"attackrange":    300,
		"damageradius":   100,
		"attackinterval": 16,
		"preattackdelay": 0,
		"bulletlifetime": 15,
		"decaydamage":    4,
		"estimatedcost":  4000,
	},
	"buran": map[string]interface{}{
		"mass":           0,
		"radius":         95,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4500},
		"sight":          375,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Laser,
		"attackdamage":   []int{28},
		"attackrange":    375,
		"attackinterval": 4,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "beholder",
				"unit":         "beholder",
				"castduration": 50,
				"precastdelay": 20,
			},
			"leader": map[string]interface{}{
				"name":                "amplify",
				"amplifydamagepersec": []int{2},
				"amplifycountlimit":   10,
			},
		},
		"estimatedcost": 0,
	},
	"cannon": map[string]interface{}{
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         30,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             []int{900},
		"sight":          275,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   []int{135},
		"attackrange":    275,
		"attackinterval": 8,
		"preattackdelay": 0,
		"bulletlifetime": 5,
		"decaydamage":    3,
		"estimatedcost":  2000,
	},
	"champion": map[string]interface{}{
		"type":                    Squire,
		"layer":                   Normal,
		"mass":                    28,
		"radius":                  35,
		"hp":                      []int{600},
		"shield":                  []int{1800},
		"sight":                   275,
		"speed":                   100,
		"targettypes":             UnitTypes{Squire, Building, Knight},
		"targetlayers":            UnitLayers{Normal},
		"damagetype":              AntiShield | Melee,
		"attackdamage":            []int{120},
		"attackrange":             55,
		"damageradius":            50,
		"attackinterval":          13,
		"preattackdelay":          5,
		"chargedelay":             20,
		"chargedmovespeed":        300,
		"chargedattackdamagetype": AntiShield | Melee,
		"chargedattackdamage":     []int{240},
		"chargedattackinterval":   7,
		"chargedattackpredelay":   4,
		"estimatedcost":           4000,
	},
	"drillram": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           40,
		"radius":         50,
		"hp":             []int{1500},
		"sight":          475,
		"speed":          200,
		"targettypes":    UnitTypes{Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Melee | Siege,
		"attackdamage":   []int{46},
		"attackrange":    70,
		"attackinterval": 2,
		"preattackdelay": 0,
		"estimatedcost":  4000,
	},
	"enforcer": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           32,
		"radius":         40,
		"hp":             []int{1350},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Melee,
		"attackdamage":   []int{190},
		"attackrange":    60,
		"attackradius":   80,
		"attackinterval": 15,
		"preattackdelay": 1,
		"estimatedcost":  4000,
	},
	"felhound": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         40,
		"hp":             []int{630},
		"shield":         []int{1890},
		"sight":          275,
		"speed":          200,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Melee,
		"attackdamage":   []int{330},
		"attackrange":    60,
		"attackinterval": 30,
		"preattackdelay": 10,
		"estimatedcost":  2500,
	},
	"footman": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             []int{400},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Melee,
		"attackdamage":   []int{75},
		"attackrange":    45,
		"attackinterval": 15,
		"preattackdelay": 5,
		"estimatedcost":  1250,
	},
	"frost": map[string]interface{}{
		"mass":           0,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4500},
		"sight":          375,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   []int{140},
		"attackrange":    375,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 2,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":           "freeze",
				"radius":         250,
				"castduration":   20,
				"freezeduration": 50,
				"precastdelay":   10,
			},
			"leader": map[string]interface{}{
				"name":         "frozenbullet",
				"slowduration": []int{30},
			},
		},
		"estimatedcost": 0,
	},
	"gargoyle": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           5,
		"radius":         27,
		"hp":             []int{180},
		"shield":         []int{540},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Melee,
		"attackdamage":   []int{40},
		"attackrange":    100,
		"attackinterval": 10,
		"preattackdelay": 5,
		"estimatedcost":  1000,
	},
	"gargoyleking": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           22,
		"radius":         37,
		"hp":             []int{750},
		"shield":         []int{2250},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Melee,
		"attackdamage":   []int{200},
		"attackrange":    100,
		"attackinterval": 15,
		"preattackdelay": 5,
		"estimatedcost":  3000,
	},
	"giant": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           50,
		"radius":         50,
		"hp":             []int{2700},
		"sight":          375,
		"speed":          75,
		"targettypes":    UnitTypes{Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Melee | Siege,
		"attackdamage":   []int{57},
		"attackrange":    70,
		"attackinterval": 2,
		"preattackdelay": 0,
		"estimatedcost":  5000,
	},
	"heavymissile": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           3,
		"radius":         50,
		"hp":             []int{350},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     DecreaseOnKnight | Melee | Death,
		"attackdamage":   []int{500},
		"attackrange":    100,
		"attackradius":   150,
		"preattackdelay": 3,
		"estimatedcost":  1333,
	},
	"ironcoffin": map[string]interface{}{
		"mass":           0,
		"radius":         65,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4600},
		"sight":          375,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Missile,
		"attackdamage":   []int{140},
		"attackrange":    375,
		"attackinterval": 20,
		"preattackdelay": 13,
		"bulletlifetime": 20,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "sentryshelter",
				"unit":         "sentryshelter",
				"castduration": 50,
				"precastdelay": 20,
			},
			"leader": map[string]interface{}{
				"name":    "gathersentry",
				"unit":    "sentry",
				"perstep": 100,
			},
		},
		"estimatedcost": 0,
	},
	"jouster": map[string]interface{}{
		"type":                    Squire,
		"layer":                   Normal,
		"mass":                    35,
		"radius":                  35,
		"hp":                      []int{1650},
		"sight":                   275,
		"speed":                   100,
		"targettypes":             UnitTypes{Squire, Building, Knight},
		"targetlayers":            UnitLayers{Normal},
		"damagetype":              AntiShield | Melee,
		"attackdamage":            []int{270},
		"attackrange":             55,
		"attackinterval":          14,
		"preattackdelay":          5,
		"chargedelay":             20,
		"chargedmovespeed":        300,
		"chargedattackdamagetype": AntiShield | Melee,
		"chargedattackdamage":     []int{520},
		"chargedattackinterval":   6,
		"chargedattackpredelay":   3,
		"estimatedcost":           5000,
	},
	"judge": map[string]interface{}{
		"mass":           0,
		"radius":         60,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4700},
		"sight":          400,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   []int{140},
		"attackrange":    400,
		"attackinterval": 20,
		"preattackdelay": 1,
		"bulletlifetime": 2,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "bulletrain",
				"damagetype":   DecreaseOnKnight | Skill,
				"damage":       []int{350},
				"radius":       200,
				"castduration": 20,
				"precastdelay": 10,
			},
			"leader": map[string]interface{}{
				"name":             "morerange",
				"attackrangeratio": []int{110},
			},
		},
		"estimatedcost": 0,
	},
	"lancer": map[string]interface{}{
		"mass":           0,
		"radius":         85,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4500},
		"sight":          375,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Missile,
		"attackdamage":   []int{154},
		"attackrange":    375,
		"attackinterval": 22,
		"preattackdelay": 17,
		"bulletlifetime": 22,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":           "napalm",
				"castduration":   30,
				"precastdelay":   15,
				"damagetype":     DecreaseOnKnight | Skill,
				"damageduration": 80,
				"damage":         []int{105},
				"width":          200,
				"height":         400,
			},
			"leader": map[string]interface{}{
				"name":       "deathcarpet",
				"duration":   600,
				"damagetype": DecreaseOnKnight | Skill,
				"damage":     []int{93},
				"count":      2,
				"posX":       []int{225, 775}, // pos based on blue side
				"posY":       []int{850, 850},
				"width":      75,
				"height":     50,
			},
		},
		"estimatedcost": 0,
	},
	"legion": map[string]interface{}{
		"mass":           0,
		"radius":         55,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4600},
		"sight":          375,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   []int{14},
		"attackrange":    375,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "fireball",
				"damagetype":   DecreaseOnKnight | Skill,
				"damage":       []int{720},
				"radius":       125,
				"castduration": 30,
				"precastdelay": 15,
			},
			"leader": map[string]interface{}{
				"name":              "morefire",
				"attackdamageratio": []int{110},
			},
		},
		"estimatedcost": 0,
	},
	"micromissile": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           1,
		"radius":         25,
		"hp":             []int{60},
		"sight":          275,
		"speed":          300,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Death | Melee,
		"attackdamage":   []int{95},
		"attackrange":    35,
		"attackradius":   80,
		"preattackdelay": 3,
		"estimatedcost":  250,
	},
	"nagmash": map[string]interface{}{
		"mass":           0,
		"radius":         85,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4500},
		"sight":          375,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Laser,
		"attackdamage":   []int{28},
		"attackrange":    375,
		"attackinterval": 4,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "unload",
				"unit":         "footman",
				"count":        4,
				"offsetX":      []int{-30, 30, -30, 30},
				"offsetY":      []int{-30, -30, 30, 30},
				"caster":       "nagmash",
				"castduration": 50,
				"precastdelay": 18,
			},
			"leader": map[string]interface{}{
				"name":    "gatherfootman",
				"unit":    "footman",
				"count":   4,
				"offsetX": []int{-30, 30, -30, 30},
				"offsetY": []int{-30, -30, 30, 30},
				"perstep": 300,
			},
		},
		"estimatedcost": 0,
	},
	"nukemissile": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           40,
		"radius":         40,
		"hp":             []int{1700},
		"sight":          275,
		"speed":          75,
		"targettypes":    UnitTypes{Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Melee | Death,
		"attackdamage":   []int{2350},
		"attackrange":    60,
		"attackradius":   200,
		"preattackdelay": 3,
		"estimatedcost":  5000,
	},
	"ogre": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           56,
		"radius":         40,
		"hp":             []int{3100},
		"sight":          250,
		"speed":          75,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Melee,
		"attackdamage":   []int{550},
		"attackrange":    60,
		"attackinterval": 20,
		"preattackdelay": 6,
		"estimatedcost":  7000,
	},
	"panzerkunstler": map[string]interface{}{
		"type":                    Squire,
		"layer":                   Normal,
		"mass":                    35,
		"radius":                  35,
		"hp":                      []int{1000},
		"shield":                  []int{3000},
		"sight":                   250,
		"speed":                   100,
		"targettypes":             UnitTypes{Squire, Building, Knight},
		"targetlayers":            UnitLayers{Normal},
		"damagetype":              Melee,
		"attackdamage":            []int{400},
		"attackrange":             100,
		"attackinterval":          30,
		"preattackdelay":          15,
		"powerattackdamagetype":   DecreaseOnKnight | Melee,
		"powerattackdamage":       []int{550},
		"powerattackdamageradius": 120,
		"powerattackinterval":     50,
		"powerattackpredelay":     33,
		"powerattackfrequency":    3,
		"powerattackradius":       350,
		"powerattackforce":        2000,
		"estimatedcost":           5000,
	},
	"pixie": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           1,
		"radius":         15,
		"hp":             []int{40},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Melee,
		"attackdamage":   []int{60},
		"attackrange":    35,
		"attackinterval": 20,
		"preattackdelay": 4,
		"estimatedcost":  333,
	},
	"pixiegeode": map[string]interface{}{
		"type":          Building,
		"layer":         Normal,
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            []int{400},
		"spawn":         "pixie",
		"spawninterval": 30,
		"spawncount":    1,
		"spawnoffsetX":  []int{0},
		"spawnoffsetY":  []int{0},
		"decaydamage":   2,
		"estimatedcost": 0,
	},
	"pixieking": map[string]interface{}{
		"mass":           0,
		"radius":         60,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4600},
		"sight":          375,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Bullet,
		"attackdamage":   []int{70},
		"attackrange":    375,
		"attackinterval": 10,
		"preattackdelay": 1,
		"bulletlifetime": 8,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "pixiegeode",
				"unit":         "pixiegeode",
				"castduration": 50,
				"precastdelay": 20,
			},
			"leader": map[string]interface{}{
				"name":    "pixiemarch",
				"unit":    "pixie",
				"perstep": 300,
				"count":   8,
				"offsetX": []int{-105, -75, -45, -15, 15, 45, 75, 105},
				"offsetY": []int{0, 0, 0, 0, 0, 0, 0, 0},
			},
		},
		"estimatedcost": 0,
	},
	"psabu": map[string]interface{}{
		"type":               Squire,
		"layer":              Normal,
		"mass":               63,
		"radius":             45,
		"hp":                 []int{1300},
		"shield":             []int{3900},
		"sight":              200,
		"speed":              100,
		"targettypes":        UnitTypes{Squire, Building, Knight},
		"targetlayers":       UnitLayers{Normal},
		"damagetype":         Melee,
		"attackdamage":       []int{150},
		"attackrange":        150,
		"attackinterval":     50,
		"attackradius":       100,
		"preattackdelay":     28,
		"absorbforce":        2000,
		"absorbdamagetype":   DecreaseOnKnight | Melee,
		"absorbdamage":       5,
		"absorbdamageradius": 150,
		"absorbradius":       300,
		"estimatedcost":      7000,
	},
	"sentry": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           2,
		"radius":         20,
		"hp":             []int{90},
		"sight":          275,
		"speed":          200,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Bullet,
		"attackdamage":   []int{35},
		"attackrange":    250,
		"attackinterval": 13,
		"preattackdelay": 0,
		"bulletlifetime": 6,
		"estimatedcost":  666,
	},
	"sentryshelter": map[string]interface{}{
		"type":          Building,
		"layer":         Normal,
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            []int{800},
		"spawn":         "sentry",
		"spawninterval": 45,
		"spawncount":    1,
		"spawnoffsetX":  []int{0},
		"spawnoffsetY":  []int{0},
		"decaydamage":   2,
		"estimatedcost": 0,
	},
	"shadowvision": map[string]interface{}{
		"type":           Squire,
		"layer":          Ether,
		"mass":           32,
		"radius":         40,
		"hp":             []int{400},
		"shield":         []int{1200},
		"sight":          250,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Missile,
		"attackdamage":   []int{150},
		"attackrange":    175,
		"damageradius":   75,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 20,
		"estimatedcost":  4000,
	},
	"starfire": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           24,
		"radius":         30,
		"hp":             []int{550},
		"sight":          300,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Bullet,
		"attackdamage":   []int{155},
		"attackrange":    300,
		"attackinterval": 11,
		"preattackdelay": 0,
		"bulletlifetime": 6,
		"estimatedcost":  4000,
	},
	"tombstone": map[string]interface{}{
		"mass":           0,
		"radius":         85,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4600},
		"sight":          375,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Laser,
		"attackdamage":   []int{28},
		"attackrange":    375,
		"attackinterval": 4,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "barrack",
				"unit":         "barrack",
				"count":        1,
				"offsetX":      []int{0},
				"offsetY":      []int{0},
				"castduration": 50,
				"precastdelay": 20,
			},
			"leader": map[string]interface{}{
				"name":      "lemming",
				"unit":      "footman",
				"count":     1,
				"offsetX":   150,
				"perdeaths": 4,
			},
		},
		"estimatedcost": 0,
	},
	"trainee": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           3,
		"radius":         24,
		"hp":             []int{110},
		"sight":          275,
		"speed":          200,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     Melee,
		"attackdamage":   []int{48},
		"attackrange":    44,
		"attackinterval": 12,
		"preattackdelay": 5,
		"estimatedcost":  666,
	},
	"valkyrie": map[string]interface{}{
		"mass":           0,
		"radius":         60,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4700},
		"sight":          375,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"damagetype":     AntiShield | Missile,
		"attackdamage":   []int{140},
		"attackrange":    375,
		"attackinterval": 20,
		"preattackdelay": 15,
		"bulletlifetime": 20,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "emp",
				"damagetype":   DecreaseOnKnight | Skill,
				"damage":       []int{140},
				"radius":       200,
				"castduration": 20,
				"precastdelay": 10,
			},
			"leader": map[string]interface{}{
				"name":    "threatmissile",
				"unit":    "micromissile",
				"perstep": 300,
				"count":   10,
				"offsetX": []int{-250, -200, -150, -100, -50, 50, 100, 150, 200, 250},
				"offsetY": []int{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			},
		},
		"estimatedcost": 1000,
	},
	"voidcreeper": map[string]interface{}{
		"type":              Squire,
		"layer":             Normal,
		"mass":              45,
		"radius":            45,
		"hp":                []int{1750},
		"sight":             275,
		"speed":             100,
		"targettypes":       UnitTypes{Squire, Building, Knight},
		"targetlayers":      UnitLayers{Normal},
		"damagetype":        AntiShield | Melee,
		"attackdamage":      []int{270},
		"damageradius":      50,
		"attackrange":       75,
		"attackinterval":    15,
		"preattackdelay":    5,
		"destroydamagetype": DecreaseOnKnight | Melee | Death,
		"destroydamage":     []int{400},
		"destroyradius":     175,
		"estimatedcost":     5000,
	},
	"wasp": map[string]interface{}{
		"type":              Squire,
		"layer":             Normal,
		"mass":              55,
		"radius":            55,
		"hp":                []int{1400},
		"shield":            []int{4200},
		"sight":             375,
		"speed":             100,
		"targettypes":       UnitTypes{Building, Knight},
		"targetlayers":      UnitLayers{Normal},
		"damagetype":        Melee,
		"attackdamage":      []int{600},
		"attackrange":       75,
		"attackinterval":    30,
		"preattackdelay":    7,
		"destroydamagetype": DecreaseOnKnight | Melee | Death,
		"destroydamage":     []int{400},
		"destroyradius":     175,
		"estimatedcost":     5000,
	},
}

func init() {
	for k, v := range Units {
		fillStatByLevel(k, v)
	}
}

func fillStatByLevel(key string, src interface{}) []int {
	switch src.(type) {
	case Unit:
		dst := src.(Unit)
		for k, v := range dst {
			if statSlice := fillStatByLevel(k, v); statSlice != nil {
				dst[k] = statSlice
			}
		}
		return nil
	case map[string]interface{}:
		dst := src.(map[string]interface{})
		for k, v := range dst {
			if statSlice := fillStatByLevel(k, v); statSlice != nil {
				dst[k] = statSlice
			}
		}
		return nil
	case []int:
		switch key {
		case "hp", "shield",
			"attackdamage", "destroydamage",
			"chargedattackdamage", "powerattackdamage",
			"damage",
			"hpratio", "attackdamageratio", "attackrangeratio",
			"amplifydamagepersec",
			"expanddamageradius",
			"slowduration":
			statSlice := src.([]int)[:1]
			baseValue := statSlice[0]
			multiplier := StatMultiplier
			for i := 0; i < LevelMax; i++ {
				statSlice = append(statSlice, baseValue*multiplier/100)
				multiplier = multiplier * StatMultiplier / 100
			}
			return statSlice
		default:
			return nil
		}
	default:
		return nil
	}
}
