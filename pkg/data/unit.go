package data

type UnitType string
type UnitTypes []UnitType

const (
	Knight   UnitType = "Knight"
	Troop    UnitType = "Troop"
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

type Unit map[string]interface{}

var Units = map[string]Unit{
	"archengineer": map[string]interface{}{
		"mass":           0,
		"radius":         75,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    330,
		"attackinterval": 30,
		"preattackdelay": 10,
		"bulletlifetime": 10,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "blastturret",
				"castduration": 100,
				"precastdelay": 78,
			},
			"leader": map[string]interface{}{
				"name":      "louder",
				"arearatio": 120,
			},
		},
	},
	"archer": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             []int{125},
		"sight":          350,
		"speed":          100,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{40, 60, 90},
		"attackrange":    250,
		"attackinterval": 12,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"archsapper": map[string]interface{}{
		"mass":           0,
		"radius":         75,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    350,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "cannon",
				"castduration": 100,
				"precastdelay": 82,
			},
			"leader": map[string]interface{}{
				"name":    "readycannon",
				"unit":    "cannon",
				"count":   2,
				"posX":    []int{325, 675}, // pos based on blue side
				"posY":    []int{1075, 1075},
				"hpratio": []int{300, 310, 320},
			},
		},
	},
	"astra": map[string]interface{}{
		"mass":           1000,
		"radius":         95,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{5},
		"attackrange":    350,
		"attackinterval": 1,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":     "megalaser",
				"duration": 80,
				"start":    10,
				"end":      58,
				"damage":   []int{10, 15, 20},
				"width":    25,
				"height":   500,
			},
			"leader": map[string]interface{}{
				"name":    "reinforce",
				"hpratio": []int{120, 130, 140},
			},
		},
	},
	"barrack": map[string]interface{}{
		"type":          Building,
		"layer":         Normal,
		"mass":          0,
		"radius":        60,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            []int{1100},
		"spawn":         "footman",
		"spawninterval": 140,
		"spawncount":    2,
		"spawnoffsetX":  []int{-20, 20},
		"spawnoffsetY":  []int{0, 0},
		"decaydamage":   1,
	},
	"berserker": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         30,
		"hp":             []int{600},
		"sight":          350,
		"speed":          150,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{325, 70, 100},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"blaster": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           10,
		"radius":         30,
		"hp":             []int{150},
		"sight":          400,
		"speed":          150,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{100, 450, 600},
		"attackrange":    250,
		"attackinterval": 19,
		"preattackdelay": 0,
		"bulletlifetime": 19,
	},
	"blastturret": map[string]interface{}{
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         40,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             []int{640},
		"sight":          350,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{100},
		"attackrange":    300,
		"attackinterval": 16,
		"preattackdelay": 0,
		"bulletlifetime": 15,
		"decaydamage":    1,
	},
	"cannon": map[string]interface{}{
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         30,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             []int{350},
		"sight":          350,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{60},
		"attackrange":    275,
		"attackinterval": 8,
		"preattackdelay": 0,
		"bulletlifetime": 5,
		"decaydamage":    1,
	},
	"champion": map[string]interface{}{
		"type":                  Troop,
		"layer":                 Normal,
		"mass":                  6,
		"radius":                30,
		"hp":                    []int{775},
		"shield":                []int{150},
		"sight":                 350,
		"speed":                 100,
		"targettypes":           UnitTypes{Troop, Building, Knight},
		"targetlayers":          UnitLayers{Normal},
		"attackdamage":          []int{155, 70, 100},
		"attackrange":           40,
		"attackinterval":        13,
		"preattackdelay":        5,
		"chargedelay":           20,
		"chargedmovespeed":      300,
		"chargedattackdamage":   []int{310, 450, 550},
		"chargedattackinterval": 7,
		"chargedattackpredelay": 4,
	},
	"drillram": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           10,
		"radius":         30,
		"hp":             []int{800},
		"sight":          350,
		"speed":          200,
		"targettypes":    UnitTypes{Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{210, 60, 90},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 9,
	},
	"enforcer": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         40,
		"hp":             []int{880},
		"sight":          350,
		"speed":          100,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{312, 70, 100},
		"attackrange":    40,
		"attackradius":   80,
		"attackinterval": 40,
		"preattackdelay": 10,
	},
	"felhound": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           10,
		"radius":         15,
		"hp":             []int{32},
		"shield":         []int{50},
		"sight":          350,
		"speed":          200,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{96, 60, 90},
		"attackrange":    30,
		"attackinterval": 30,
		"preattackdelay": 10,
	},
	"footman": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             []int{300},
		"sight":          350,
		"speed":          100,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{75, 70, 100},
		"attackrange":    40,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"frost": map[string]interface{}{
		"mass":           0,
		"radius":         70,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{100},
		"attackrange":    350,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 2,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "freeze",
				"radius":       100,
				"castduration": 70,
				"precastdelay": 20,
			},
			"leader": map[string]interface{}{
				"name":         "frozenbullet",
				"slowduration": []int{20},
			},
		},
	},
	"gargoyle": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             []int{90},
		"shield":         []int{50},
		"sight":          350,
		"speed":          150,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{40, 60, 90},
		"attackrange":    100,
		"attackinterval": 10,
		"preattackdelay": 5,
	},
	"gargoyleking": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         35,
		"hp":             []int{395},
		"shield":         []int{100},
		"sight":          350,
		"speed":          100,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{147, 60, 90},
		"attackrange":    100,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"giant": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           60,
		"radius":         60,
		"hp":             []int{2000},
		"sight":          350,
		"speed":          75,
		"targettypes":    UnitTypes{Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{163, 60, 90},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 8,
	},
	"ironcoffin": map[string]interface{}{
		"mass":           1000,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{75},
		"attackrange":    350,
		"attackinterval": 15,
		"preattackdelay": 0,
		"bulletlifetime": 15,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "sentryshelter",
				"castduration": 50,
				"precastdelay": 20,
			},
			"leader": map[string]interface{}{
				"name":    "gathersentry",
				"unit":    "sentry",
				"perstep": 300,
			},
		},
	},
	"jouster": map[string]interface{}{
		"type":                  Troop,
		"layer":                 Normal,
		"mass":                  6,
		"radius":                30,
		"hp":                    []int{1215},
		"sight":                 350,
		"speed":                 100,
		"targettypes":           UnitTypes{Troop, Building, Knight},
		"targetlayers":          UnitLayers{Normal},
		"attackdamage":          []int{245, 70, 100},
		"attackrange":           40,
		"attackinterval":        14,
		"preattackdelay":        5,
		"chargedelay":           20,
		"chargedmovespeed":      300,
		"chargedattackdamage":   []int{490, 450, 550},
		"chargedattackinterval": 6,
		"chargedattackpredelay": 3,
	},
	"judge": map[string]interface{}{
		"mass":           0,
		"radius":         85,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{100},
		"attackrange":    375,
		"attackinterval": 20,
		"preattackdelay": 1,
		"bulletlifetime": 2,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "bulletrain",
				"damage":       []int{300, 400, 500},
				"radius":       70,
				"castduration": 50,
				"precastdelay": 20,
			},
			"leader": map[string]interface{}{
				"name":             "morerange",
				"attackrangeratio": []int{120, 130, 140},
			},
		},
	},
	"lancer": map[string]interface{}{
		"mass":           1000,
		"radius":         105,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    350,
		"attackinterval": 22,
		"preattackdelay": 0,
		"bulletlifetime": 22,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":           "napalm",
				"castduration":   40,
				"precastdelay":   25,
				"damageduration": 50,
				"damage":         30,
				"width":          100,
				"height":         100,
			},
			"leader": map[string]interface{}{
				"name":     "deathcarpet",
				"duration": 600,
				"damage":   30,
				"count":    2,
				"posX":     []int{225, 775}, // pos based on blue side
				"posY":     []int{850, 850},
				"width":    75,
				"height":   50,
			},
		},
	},
	"legion": map[string]interface{}{
		"mass":           0,
		"radius":         70,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    350,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"skill": map[string]interface{}{
			"wing": map[string]interface{}{
				"name":         "fireball",
				"damage":       []int{325, 400, 500},
				"radius":       70,
				"castduration": 40,
				"precastdelay": 20,
			},
			"leader": map[string]interface{}{
				"name":              "moredamage",
				"attackdamageratio": []int{110, 130, 140},
			},
		},
	},
	"nagmash": map[string]interface{}{
		"mass":           1000,
		"radius":         105,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{5},
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
				"castduration": 100,
				"precastdelay": 52,
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
	"ogre": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         35,
		"hp":             []int{2610},
		"sight":          350,
		"speed":          75,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{500, 70, 100},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"panzerkunstler": map[string]interface{}{
		"type":                 Troop,
		"layer":                Normal,
		"mass":                 6,
		"radius":               30,
		"hp":                   []int{800},
		"sight":                350,
		"speed":                100,
		"targettypes":          UnitTypes{Troop, Building, Knight},
		"targetlayers":         UnitLayers{Normal},
		"attackdamage":         []int{500, 70, 100},
		"attackrange":          40,
		"attackinterval":       30,
		"preattackdelay":       15,
		"powerattackdamage":    []int{100, 200, 300},
		"powerattackinterval":  50,
		"powerattackpredelay":  33,
		"powerattackfrequency": 3,
		"powerattackradius":    300,
		"powerattackforce":     3000,
	},
	"pixie": map[string]interface{}{
		"type":           Troop,
		"layer":          Ether,
		"mass":           6,
		"radius":         15,
		"hp":             []int{30},
		"sight":          350,
		"speed":          150,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{60, 70, 100},
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
		"hp":            []int{1100},
		"spawn":         "pixie",
		"spawninterval": 140,
		"spawncount":    1,
		"spawnoffsetX":  []int{0},
		"spawnoffsetY":  []int{0},
		"decaydamage":   1,
	},
	"pixieking": map[string]interface{}{
		"mass":           1000,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{50},
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
		"type":           Troop,
		"layer":          Normal,
		"mass":           60,
		"radius":         40,
		"hp":             []int{2700},
		"shield":         []int{500},
		"sight":          350,
		"speed":          100,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{800, 60, 90},
		"attackrange":    30,
		"attackinterval": 50,
		"attackradius":   80,
		"preattackdelay": 28,
		"absorbforce":    2000,
		"absorbdamage":   2,
		"absorbradius":   500,
	},
	"sentry": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             []int{52},
		"sight":          350,
		"speed":          200,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{24, 60, 90},
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
		"hp":            []int{1100},
		"spawn":         "sentry",
		"spawninterval": 140,
		"spawncount":    1,
		"spawnoffsetX":  []int{0},
		"spawnoffsetY":  []int{0},
		"decaydamage":   1,
	},
	"shadowvision": map[string]interface{}{
		"type":           Troop,
		"layer":          Ether,
		"mass":           20,
		"radius":         35,
		"hp":             []int{800},
		"shield":         300,
		"sight":          400,
		"speed":          150,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{300, 450, 600},
		"attackrange":    175,
		"attackinterval": 20,
		"preattackdelay": 0,
		"bulletlifetime": 20,
	},
	"starfire": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         30,
		"hp":             []int{340},
		"sight":          350,
		"speed":          100,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{100, 60, 90},
		"attackrange":    300,
		"attackinterval": 11,
		"preattackdelay": 0,
		"bulletlifetime": 6,
	},
	"tombstone": map[string]interface{}{
		"mass":           1000,
		"radius":         110,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"speed":          300,
		"targettypes":    UnitTypes{Troop},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{5},
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
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             []int{50},
		"sight":          350,
		"speed":          200,
		"targettypes":    UnitTypes{Troop, Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{48, 70, 100},
		"attackrange":    40,
		"attackinterval": 12,
		"preattackdelay": 5,
	},
	"wasp": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             []int{1050},
		"shield":         []int{500},
		"sight":          300,
		"speed":          100,
		"targettypes":    UnitTypes{Building, Knight},
		"targetlayers":   UnitLayers{Normal},
		"attackdamage":   []int{600, 60, 90},
		"attackrange":    75,
		"attackinterval": 10,
		"preattackdelay": 7,
		"destroydamage":  []int{600},
		"destroyradius":  100,
	},
}
