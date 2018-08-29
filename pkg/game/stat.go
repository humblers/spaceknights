package game

const ShieldRegenPerStep = 2
const HoverKnightTileOffsetX = 2

var cards = map[string]map[string]interface{}{
	"archers": map[string]interface{}{
		"cost":    3000,
		"unit":    "archer",
		"count":   2,
		"offsetX": []int{-40, 40},
		"offsetY": []int{0, 0},
	},
	"cannon": map[string]interface{}{
		"cost":         3000,
		"unit":         "cannon",
		"count":        1,
		"offsetX":      []int{0},
		"offsetY":      []int{0},
		"caster":       "archsapper",
		"castduration": 100,
		"precastdelay": 82,
	},
	"barrack": map[string]interface{}{
		"cost":         7000,
		"unit":         "barrack",
		"count":        1,
		"offsetX":      []int{0},
		"offsetY":      []int{0},
		"caster":       "tombstone",
		"castduration": 50,
		"precastdelay": 20,
	},
	"footmans": map[string]interface{}{
		"cost":    5000,
		"unit":    "footman",
		"count":   4,
		"offsetX": []int{-30, 30, -30, 30},
		"offsetY": []int{-30, -30, 30, 30},
	},
	"enforcer": map[string]interface{}{
		"cost":    4000,
		"unit":    "enforcer",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"jouster": map[string]interface{}{
		"cost":    5000,
		"unit":    "jouster",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"fireball": map[string]interface{}{
		"cost":         4000,
		"caster":       "legion",
		"damage":       []int{325, 400, 500},
		"radius":       70,
		"castduration": 40,
		"precastdelay": 20,
	},
	"bulletrain": map[string]interface{}{
		"cost":         3000,
		"caster":       "judge",
		"damage":       []int{300, 400, 500},
		"radius":       70,
		"castduration": 50,
		"precastdelay": 20,
	},
	"gargoylehorde": map[string]interface{}{
		"cost":    5000,
		"unit":    "gargoyle",
		"count":   6,
		"offsetX": []int{-40, 0, 40, -40, 0, 40},
		"offsetY": []int{-20, -20, -20, 20, 20, 20},
	},
	"giant": map[string]interface{}{
		"cost":    5000,
		"unit":    "giant",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"unload": map[string]interface{}{
		"cost":         4000,
		"unit":         "footman",
		"count":        4,
		"offsetX":      []int{-30, 30, -30, 30},
		"offsetY":      []int{-30, -30, 30, 30},
		"caster":       "nagmash",
		"castduration": 100,
		"precastdelay": 52,
	},
	"megalaser": map[string]interface{}{
		"cost":     4000,
		"caster":   "astra",
		"duration": 80,
		"start":    10,
		"end":      58,
		"damage":   []int{10, 15, 20},
		"width":    25,
		"height":   500,
	},
	"psabu": map[string]interface{}{
		"cost":    7000,
		"unit":    "psabu",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"felhound": map[string]interface{}{
		"cost":    2000,
		"unit":    "felhound",
		"count":   5,
		"offsetX": []int{-60, 0, 60, -30, 30},
		"offsetY": []int{-30, -30, -30, 30, 30},
	},
	"shadowvision": map[string]interface{}{
		"cost":    4000,
		"unit":    "shadowvision",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"panzerkunstler": map[string]interface{}{
		"cost":    5000,
		"unit":    "panzerkunstler",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"trainee": map[string]interface{}{
		"cost":    2000,
		"unit":    "trainee",
		"count":   3,
		"offsetX": []int{-30, 30, 0},
		"offsetY": []int{30, 30, 0},
	},
	"starfire": map[string]interface{}{
		"cost":    4000,
		"unit":    "starfire",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"threestarfires": map[string]interface{}{
		"cost":    9000,
		"unit":    "starfire",
		"count":   3,
		"offsetX": []int{-60, 60, 0},
		"offsetY": []int{60, 60, 0},
	},
	"pixie": map[string]interface{}{
		"cost":    1000,
		"unit":    "pixie",
		"count":   3,
		"offsetX": []int{-30, 30, 0},
		"offsetY": []int{30, 30, 0},
	},
	"gargoyleking": map[string]interface{}{
		"cost":    3000,
		"unit":    "gargoyleking",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"berserker": map[string]interface{}{
		"cost":    4000,
		"unit":    "berserker",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"ogre": map[string]interface{}{
		"cost":    7000,
		"unit":    "ogre",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"wasp": map[string]interface{}{
		"cost":    5000,
		"unit":    "wasp",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
}

var passives = map[string]map[string]interface{}{
	"gatherfootman": map[string]interface{}{
		"unit":    "footman",
		"count":   4,
		"offsetX": []int{-30, 30, -30, 30},
		"offsetY": []int{-30, -30, 30, 30},
		"perstep": 300,
	},
	"lemming": map[string]interface{}{
		"unit":      "footman",
		"count":     1,
		"offsetX":   150,
		"perdeaths": 4,
	},
	"moredamage": map[string]interface{}{
		"attackdamageratio": []int{110, 130, 140},
	},
	"morerange": map[string]interface{}{
		"attackrangeratio": []int{120, 130, 140},
	},
	"readycannon": map[string]interface{}{
		"unit":    "cannon",
		"count":   2,
		"posX":    []int{325, 675}, // pos based on blue side
		"posY":    []int{1075, 1075},
		"hpratio": []int{300, 310, 320},
	},
	"reinforce": map[string]interface{}{
		"hpratio": []int{120, 130, 140},
	},
}

var units = map[string]map[string]interface{}{
	"archer": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             []int{125},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{40, 60, 90},
		"attackrange":    300,
		"attackinterval": 12,
		"preattackdelay": 0,
		"bulletlifetime": 4,
	},
	"archsapper": map[string]interface{}{
		"mass":           0,
		"radius":         60,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"active":         "cannon",
		"passive":        "readycannon",
	},
	"tombstone": map[string]interface{}{
		"mass":           1000,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"speed":          300,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    330,
		"attackinterval": 10,
		"active":         "barrack",
		"passive":        "lemming",
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
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{60},
		"attackrange":    350,
		"attackinterval": 8,
		"preattackdelay": 0,
		"bulletlifetime": 4,
		"decaydamage":    1,
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
	"footman": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             []int{300},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{75, 70, 100},
		"attackrange":    40,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"enforcer": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         40,
		"hp":             []int{880},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{312, 70, 100},
		"attackrange":    40,
		"attackinterval": 40,
		"preattackdelay": 10,
	},
	"panzerkunstler": map[string]interface{}{
		"type":                 Troop,
		"layer":                Normal,
		"mass":                 6,
		"radius":               30,
		"hp":                   []int{1000},
		"sight":                350,
		"speed":                100,
		"targettypes":          Types{Troop, Building, Knight},
		"targetlayers":         Layers{Normal},
		"attackdamage":         []int{40, 70, 100},
		"attackrange":          40,
		"attackinterval":       30,
		"preattackdelay":       15,
		"powerattackdamage":    []int{100, 200, 300},
		"powerattackinterval":  50,
		"powerattackpredelay":  33,
		"powerattackfrequency": 3,
		"powerattackradius":    100,
		"powerattackforce":     3000,
	},
	"jouster": map[string]interface{}{
		"type":                  Troop,
		"layer":                 Normal,
		"mass":                  6,
		"radius":                30,
		"hp":                    []int{1100},
		"sight":                 350,
		"speed":                 100,
		"targettypes":           Types{Troop, Building, Knight},
		"targetlayers":          Layers{Normal},
		"attackdamage":          []int{220, 70, 100},
		"attackrange":           40,
		"attackinterval":        10,
		"preattackdelay":        5,
		"chargedelay":           20,
		"chargedmovespeed":      300,
		"chargedattackdamage":   []int{400, 450, 550},
		"chargedattackinterval": 15,
		"chargedattackpredelay": 10,
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
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{40, 60, 90},
		"attackrange":    40,
		"attackinterval": 10,
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
		"targettypes":    Types{Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{163, 60, 90},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 8,
	},
	"legion": map[string]interface{}{
		"mass":           0,
		"radius":         45,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"speed":          800,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{10},
		"attackrange":    350,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"active":         "fireball",
		"passive":        "moredamage",
	},
	"judge": map[string]interface{}{
		"mass":           0,
		"radius":         35,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"speed":          300,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    350,
		"attackinterval": 10,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"active":         "bulletrain",
		"passive":        "morerange",
	},
	"nagmash": map[string]interface{}{
		"mass":           1000,
		"radius":         70,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"speed":          300,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"active":         "unload",
		"passive":        "gatherfootman",
	},
	"astra": map[string]interface{}{
		"mass":           1000,
		"radius":         70,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2400},
		"sight":          350,
		"speed":          300,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"active":         "megalaser",
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
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{800, 60, 90},
		"attackrange":    30,
		"attackinterval": 50,
		"attackradius":   80,
		"preattackdelay": 28,
		"absorbforce":    2000,
		"absorbdamage":   2,
		"absorbradius":   100,
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
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{96, 60, 90},
		"attackrange":    30,
		"attackinterval": 30,
		"preattackdelay": 10,
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
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{300, 450, 600},
		"attackrange":    300,
		"attackinterval": 36,
		"preattackdelay": 0,
		"bulletlifetime": 30,
	},
	"trainee": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         20,
		"hp":             []int{50},
		"sight":          350,
		"speed":          200,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{48, 70, 100},
		"attackrange":    40,
		"attackinterval": 12,
		"preattackdelay": 5,
	},
	"starfire": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         30,
		"hp":             []int{340},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{100, 60, 90},
		"attackrange":    350,
		"attackinterval": 11,
		"preattackdelay": 0,
		"bulletlifetime": 4,
	},
	"pixie": map[string]interface{}{
		"type":           Troop,
		"layer":          Ether,
		"mass":           6,
		"radius":         15,
		"hp":             []int{30},
		"sight":          350,
		"speed":          150,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{60, 70, 100},
		"attackrange":    40,
		"attackinterval": 20,
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
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{147, 60, 90},
		"attackrange":    40,
		"attackinterval": 15,
		"preattackdelay": 5,
	},
	"berserker": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         30,
		"hp":             []int{600},
		"sight":          350,
		"speed":          150,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{325, 70, 100},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"ogre": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         35,
		"hp":             []int{2610},
		"sight":          350,
		"speed":          75,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{500, 70, 100},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 6,
	},
	"wasp": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         25,
		"hp":             []int{1050},
		"shield":         []int{500},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{600, 60, 90},
		"attackrange":    75,
		"attackinterval": 10,
		"preattackdelay": 7,
		"destroydamage":  []int{600},
		"destroyradius":  100,
	},
}
