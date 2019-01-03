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

type DamageType string

const (
	NormalDamage DamageType = "Normal"
	AntiShield   DamageType = "AntiShield"
	Death        DamageType = "Death"
	Decay        DamageType = "Decay"
	Skill        DamageType = "Skill"
)

type AttackType string

const (
	Melee   AttackType = "Melee"
	Bullet  AttackType = "Bullet"
	Missile AttackType = "Missile"
	Laser   AttackType = "Laser"
)

type Unit map[string]interface{}

var Units = map[string]Unit{
	"absorber": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         40,
		"hp":             []int{1850},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{180},
		"attackrange":    40,
		"attackradius":   80,
		"attackinterval": 20,
		"preattackdelay": 9,
	},
	"archengineer": map[string]interface{}{
		"mass":           0,
		"radius":         75,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{140},
		"attackrange":    350,
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
				"name":      "louder",
				"arearatio": 200,
			},
		},
	},
	"archer": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             []int{180},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{70},
		"attackrange":    250,
		"attackinterval": 12,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"archmage": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         42,
		"hp":             []int{550},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{280},
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 17,
		"preattackdelay": 11,
		"bulletlifetime": 4,
	},
	"archsapper": map[string]interface{}{
		"mass":           0,
		"radius":         75,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{105},
		"attackrange":    350,
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
	},
	"astra": map[string]interface{}{
		"mass":           0,
		"radius":         95,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Laser,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{7},
		"attackrange":    350,
		"attackinterval": 1,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":       "megalaser",
				"duration":   40,
				"start":      11,
				"end":        31,
				"damagetype": NormalDamage,
				"damage":     []int{45},
				"width":      50,
				"height":     250,
			},
			"leader": map[string]interface{}{
				"name":    "reinforce",
				"hpratio": []int{130},
			},
		},
	},
	"azero": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         50,
		"hp":             []int{650},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{105},
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 12,
		"preattackdelay": 7,
		"bulletlifetime": 4,
		"slowduration":   80,
	},
	"barrack": map[string]interface{}{
		"type":          Building,
		"layer":         Normal,
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            []int{1800},
		"spawn":         "footman",
		"spawninterval": 80,
		"spawncount":    2,
		"spawnoffsetX":  []int{-20, 20},
		"spawnoffsetY":  []int{0, 0},
		"decaydamage":   3,
	},
	"beholder": map[string]interface{}{
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         30,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             []int{1500},
		"sight":          275,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Laser,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{5},
		"attackrange":    275,
		"attackinterval": 1,
		"decaydamage":    2,
	},
	"berserker": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           10,
		"radius":         30,
		"hp":             []int{950},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     AntiShield,
		"attackdamage":   []int{350},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"blaster": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           10,
		"radius":         30,
		"hp":             []int{400},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Missile,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{240},
		"attackrange":    250,
		"damageradius":   75,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 20,
	},
	"blastturret": map[string]interface{}{
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         40,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             []int{1500},
		"sight":          300,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Missile,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{300},
		"attackrange":    300,
		"damageradius":   100,
		"attackinterval": 16,
		"preattackdelay": 0,
		"bulletlifetime": 15,
		"decaydamage":    3,
	},
	"buran": map[string]interface{}{
		"mass":           0,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Laser,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{7},
		"attackrange":    350,
		"attackinterval": 1,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "beholder",
				"unit":         "beholder",
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
	},
	"cannon": map[string]interface{}{
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         30,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             []int{800},
		"sight":          275,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     AntiShield,
		"attackdamage":   []int{120},
		"attackrange":    275,
		"attackinterval": 8,
		"preattackdelay": 0,
		"bulletlifetime": 5,
		"decaydamage":    2,
	},
	"champion": map[string]interface{}{
		"type":                    Squire,
		"layer":                   Normal,
		"mass":                    20,
		"radius":                  30,
		"hp":                      []int{600},
		"shield":                  []int{1800},
		"sight":                   275,
		"speed":                   100,
		"targettypes":             UnitTypes{Squire, Building, Knight},
		"targetlayers":            UnitLayers{Normal},
		"attacktype":              Melee,
		"damagetype":              AntiShield,
		"attackdamage":            []int{100},
		"attackrange":             40,
		"damageradius":            50,
		"attackinterval":          13,
		"preattackdelay":          5,
		"chargedelay":             20,
		"chargedmovespeed":        300,
		"chargedattackdamagetype": AntiShield,
		"chargedattackdamage":     []int{200},
		"chargedattackinterval":   7,
		"chargedattackpredelay":   4,
	},
	"drillram": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         30,
		"hp":             []int{1200},
		"sight":          475,
		"speed":          200,
		"targettypes":    UnitTypes{Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{30},
		"attackrange":    40,
		"attackinterval": 2,
		"preattackdelay": 0,
	},
	"enforcer": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         40,
		"hp":             []int{1350},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{180},
		"attackrange":    40,
		"attackradius":   80,
		"attackinterval": 15,
		"preattackdelay": 1,
	},
	"felhound": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           10,
		"radius":         35,
		"hp":             []int{630},
		"shield":         []int{1890},
		"sight":          275,
		"speed":          200,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     AntiShield,
		"attackdamage":   []int{330},
		"attackrange":    30,
		"attackinterval": 30,
		"preattackdelay": 10,
	},
	"footman": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             []int{300},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     AntiShield,
		"attackdamage":   []int{75},
		"attackrange":    40,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"frost": map[string]interface{}{
		"mass":           0,
		"radius":         70,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{140},
		"attackrange":    350,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 2,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":           "freeze",
				"radius":         170,
				"castduration":   30,
				"freezeduration": 50,
				"precastdelay":   20,
			},
			"leader": map[string]interface{}{
				"name":         "frozenbullet",
				"slowduration": []int{30},
			},
		},
	},
	"gargoyle": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             []int{180},
		"shield":         []int{540},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{40},
		"attackrange":    100,
		"attackinterval": 10,
		"preattackdelay": 5,
	},
	"gargoyleking": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         35,
		"hp":             []int{750},
		"shield":         []int{2250},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{200},
		"attackrange":    100,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"giant": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           60,
		"radius":         60,
		"hp":             []int{2700},
		"sight":          375,
		"speed":          75,
		"targettypes":    UnitTypes{Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{45},
		"attackrange":    40,
		"attackinterval": 2,
		"preattackdelay": 0,
	},
	"heavymissile": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           10,
		"radius":         30,
		"hp":             []int{350},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     Death,
		"attackdamage":   []int{300},
		"attackrange":    35,
		"attackradius":   105,
		"preattackdelay": 3,
	},
	"ironcoffin": map[string]interface{}{
		"mass":           0,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Missile,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{140},
		"attackrange":    350,
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
	},
	"jouster": map[string]interface{}{
		"type":                    Squire,
		"layer":                   Normal,
		"mass":                    20,
		"radius":                  30,
		"hp":                      []int{1650},
		"sight":                   275,
		"speed":                   100,
		"targettypes":             UnitTypes{Squire, Building, Knight},
		"targetlayers":            UnitLayers{Normal},
		"attacktype":              Melee,
		"damagetype":              AntiShield,
		"attackdamage":            []int{260},
		"attackrange":             40,
		"attackinterval":          14,
		"preattackdelay":          5,
		"chargedelay":             20,
		"chargedmovespeed":        300,
		"chargedattackdamagetype": AntiShield,
		"chargedattackdamage":     []int{520},
		"chargedattackinterval":   6,
		"chargedattackpredelay":   3,
	},
	"judge": map[string]interface{}{
		"mass":           0,
		"radius":         85,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          400,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{140},
		"attackrange":    400,
		"attackinterval": 20,
		"preattackdelay": 1,
		"bulletlifetime": 2,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "bulletrain",
				"damagetype":   Skill,
				"damage":       []int{180},
				"radius":       200,
				"castduration": 20,
				"precastdelay": 10,
			},
			"leader": map[string]interface{}{
				"name":             "morerange",
				"attackrangeratio": []int{140},
			},
		},
	},
	"lancer": map[string]interface{}{
		"mass":           0,
		"radius":         105,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Missile,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{154},
		"attackrange":    350,
		"attackinterval": 22,
		"preattackdelay": 17,
		"bulletlifetime": 22,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":           "napalm",
				"castduration":   30,
				"precastdelay":   15,
				"damagetype":     Skill,
				"damageduration": 80,
				"damage":         []int{80},
				"width":          200,
				"height":         400,
			},
			"leader": map[string]interface{}{
				"name":       "deathcarpet",
				"duration":   600,
				"damagetype": Skill,
				"damage":     []int{150},
				"count":      2,
				"posX":       []int{225, 775}, // pos based on blue side
				"posY":       []int{850, 850},
				"width":      75,
				"height":     50,
			},
		},
	},
	"legion": map[string]interface{}{
		"mass":           0,
		"radius":         70,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{14},
		"attackrange":    350,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "fireball",
				"damagetype":   Skill,
				"damage":       []int{510},
				"radius":       125,
				"castduration": 30,
				"precastdelay": 15,
			},
			"leader": map[string]interface{}{
				"name":              "moredamage",
				"attackdamageratio": []int{130},
			},
		},
	},
	"micromissile": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           1,
		"radius":         30,
		"hp":             []int{60},
		"sight":          275,
		"speed":          300,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     Death,
		"attackdamage":   []int{95},
		"attackrange":    35,
		"attackradius":   80,
		"preattackdelay": 3,
	},
	"nagmash": map[string]interface{}{
		"mass":           0,
		"radius":         105,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Laser,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{7},
		"attackrange":    350,
		"attackinterval": 1,
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
	},
	"nukemissile": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           80,
		"radius":         50,
		"hp":             []int{1700},
		"sight":          275,
		"speed":          75,
		"targettypes":    UnitTypes{Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     Death,
		"attackdamage":   []int{1000},
		"attackrange":    55,
		"attackradius":   150,
		"preattackdelay": 3,
	},
	"ogre": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           60,
		"radius":         35,
		"hp":             []int{3100},
		"sight":          250,
		"speed":          75,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     AntiShield,
		"attackdamage":   []int{550},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"panzerkunstler": map[string]interface{}{
		"type":                    Squire,
		"layer":                   Normal,
		"mass":                    30,
		"radius":                  30,
		"hp":                      []int{1000},
		"shield":                  []int{3000},
		"sight":                   250,
		"speed":                   100,
		"targettypes":             UnitTypes{Squire, Building, Knight},
		"targetlayers":            UnitLayers{Normal},
		"attacktype":              Melee,
		"damagetype":              NormalDamage,
		"attackdamage":            []int{300},
		"attackrange":             70,
		"attackinterval":          30,
		"preattackdelay":          15,
		"powerattackdamagetype":   NormalDamage,
		"powerattackdamage":       []int{290},
		"powerattackdamageradius": 300,
		"powerattackinterval":     50,
		"powerattackpredelay":     33,
		"powerattackfrequency":    3,
		"powerattackradius":       300,
		"powerattackforce":        8000,
	},
	"pixie": map[string]interface{}{
		"type":           Squire,
		"layer":          Ether,
		"mass":           6,
		"radius":         15,
		"hp":             []int{40},
		"sight":          275,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{60},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 4,
	},
	"pixiegeode": map[string]interface{}{
		"type":          Building,
		"layer":         Normal,
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            []int{430},
		"spawn":         "pixie",
		"spawninterval": 30,
		"spawncount":    1,
		"spawnoffsetX":  []int{0},
		"spawnoffsetY":  []int{0},
		"decaydamage":   1,
	},
	"pixieking": map[string]interface{}{
		"mass":           0,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{70},
		"attackrange":    350,
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
	},
	"psabu": map[string]interface{}{
		"type":               Squire,
		"layer":              Normal,
		"mass":               60,
		"radius":             40,
		"hp":                 []int{1300},
		"shield":             []int{3900},
		"sight":              200,
		"speed":              100,
		"targettypes":        UnitTypes{Squire, Building, Knight},
		"targetlayers":       UnitLayers{Normal},
		"attacktype":         Melee,
		"damagetype":         NormalDamage,
		"attackdamage":       []int{520},
		"attackrange":        75,
		"attackinterval":     50,
		"attackradius":       160,
		"preattackdelay":     28,
		"absorbforce":        10000,
		"absorbdamagetype":   NormalDamage,
		"absorbdamage":       5,
		"absorbdamageradius": 350,
		"absorbradius":       350,
	},
	"sentry": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             []int{90},
		"sight":          275,
		"speed":          200,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{35},
		"attackrange":    250,
		"attackinterval": 13,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"sentryshelter": map[string]interface{}{
		"type":          Building,
		"layer":         Normal,
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            []int{1000},
		"spawn":         "sentry",
		"spawninterval": 45,
		"spawncount":    1,
		"spawnoffsetX":  []int{0},
		"spawnoffsetY":  []int{0},
		"decaydamage":   2,
	},
	"shadowvision": map[string]interface{}{
		"type":           Squire,
		"layer":          Ether,
		"mass":           30,
		"radius":         35,
		"hp":             []int{350},
		"shield":         []int{1050},
		"sight":          250,
		"speed":          150,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Missile,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{195},
		"attackrange":    175,
		"damageradius":   75,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 20,
	},
	"starfire": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           20,
		"radius":         30,
		"hp":             []int{550},
		"sight":          300,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Bullet,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{155},
		"attackrange":    300,
		"attackinterval": 11,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"tombstone": map[string]interface{}{
		"mass":           0,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Laser,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{7},
		"attackrange":    350,
		"attackinterval": 1,
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
	},
	"trainee": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             []int{110},
		"sight":          275,
		"speed":          200,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{48},
		"attackrange":    40,
		"attackinterval": 12,
		"preattackdelay": 5,
	},
	"valkyrie": map[string]interface{}{
		"mass":           0,
		"radius":         85,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{4400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Squire},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Missile,
		"damagetype":     NormalDamage,
		"attackdamage":   []int{140},
		"attackrange":    350,
		"attackinterval": 20,
		"preattackdelay": 15,
		"bulletlifetime": 20,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "emp",
				"damagetype":   NormalDamage,
				"damage":       []int{90},
				"radius":       200,
				"castduration": 20,
				"precastdelay": 10,
			},
			"leader": map[string]interface{}{
				"name":             "morerange",
				"attackrangeratio": []int{140},
			},
		},
	},
	"voidcreeper": map[string]interface{}{
		"type":           Squire,
		"layer":          Normal,
		"mass":           40,
		"radius":         30,
		"hp":             []int{1750},
		"sight":          275,
		"speed":          100,
		"targettypes":    UnitTypes{Squire, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attacktype":     Melee,
		"damagetype":     AntiShield,
		"attackdamage":   []int{250},
		"attackrange":    70,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"wasp": map[string]interface{}{
		"type":              Squire,
		"layer":             Normal,
		"mass":              40,
		"radius":            25,
		"hp":                []int{1400},
		"shield":            []int{4200},
		"sight":             375,
		"speed":             100,
		"targettypes":       UnitTypes{Building, Knight},
		"targetlayers":      UnitLayers{Normal},
		"attacktype":        Melee,
		"damagetype":        NormalDamage,
		"attackdamage":      []int{600},
		"attackrange":       75,
		"attackinterval":    30,
		"preattackdelay":    7,
		"destroydamagetype": Death,
		"destroydamage":     []int{400},
		"destroyradius":     175,
	},
}

func Initialize() {
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
		case "hp", "shield", "attackdamage", "destroydamage", "chargedattackdamage", "powerattackdamage", "damage", "hpratio", "attackdamageratio", "attackrangeratio", "slowduration":
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
