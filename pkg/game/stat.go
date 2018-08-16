package game

const ShieldRegenPerStep = 2

var cards = map[string]map[string]interface{}{
	"archers": map[string]interface{}{
		"cost":    1000,
		"unit":    "archer",
		"count":   2,
		"offsetX": []int{-40, 40},
		"offsetY": []int{0, 0},
	},
	"cannon": map[string]interface{}{
		"cost":         1000,
		"unit":         "cannon",
		"count":        1,
		"offsetX":      []int{0},
		"offsetY":      []int{0},
		"caster":       "archsapper",
		"castduration": 100,
		"precastdelay": 82,
	},
	"barrack": map[string]interface{}{
		"cost":         2000,
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
	"fireball": map[string]interface{}{
		"cost":         2000,
		"caster":       "legion",
		"damage":       []int{300, 400, 500},
		"radius":       70,
		"castduration": 40,
		"precastdelay": 20,
	},
	"bulletrain": map[string]interface{}{
		"cost":         2000,
		"caster":       "judge",
		"damage":       []int{300, 400, 500},
		"radius":       70,
		"castduration": 50,
		"precastdelay": 20,
	},
	"gargoylehorde": map[string]interface{}{
		"cost":    6000,
		"unit":    "gargoyle",
		"count":   6,
		"offsetX": []int{-30, 0, 30, -30, 0, 30},
		"offsetY": []int{-15, -15, -15, 15, 15, 15},
	},
	"giant": map[string]interface{}{
		"cost":    5000,
		"unit":    "giant",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
	"unload": map[string]interface{}{
		"cost":         2000,
		"unit":         "footman",
		"count":        4,
		"offsetX":      []int{-30, 30, -30, 30},
		"offsetY":      []int{-30, -30, 30, 30},
		"caster":       "nagmash",
		"castduration": 100,
		"precastdelay": 52,
	},
	"megalaser": map[string]interface{}{
		"cost":     2000,
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
	"shadowvision": map[string]interface{}{
		"cost":    3000,
		"unit":    "shadowvision",
		"count":   1,
		"offsetX": []int{0},
		"offsetY": []int{0},
	},
}

var units = map[string]map[string]interface{}{
	"archer": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         30,
		"hp":             []int{254},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{30, 60, 90},
		"attackrange":    300,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 4,
	},
	"archsapper": map[string]interface{}{
		"mass":           0,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2000},
		"sight":          350,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{150},
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"skill":          "cannon",
	},
	"tombstone": map[string]interface{}{
		"mass":           30,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2000},
		"sight":          350,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"skill":          "barrack",
	},
	"cannon": map[string]interface{}{
		"type":           Building,
		"layer":          Normal,
		"mass":           0,
		"radius":         50,
		"tilenumx":       3,
		"tilenumy":       3,
		"hp":             []int{360},
		"sight":          350,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{40},
		"attackrange":    300,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 4,
		"decaydamage":    1,
	},
	"barrack": map[string]interface{}{
		"type":          Building,
		"layer":         Normal,
		"mass":          0,
		"radius":        50,
		"tilenumx":      3,
		"tilenumy":      3,
		"hp":            []int{360},
		"spawn":         "footman",
		"spawninterval": 50,
		"spawncount":    2,
		"spawnoffsetX":  []int{-20, 20},
		"spawnoffsetY":  []int{0, 0},
		"decaydamage":   1,
	},
	"footman": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         30,
		"hp":             []int{1000},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{40, 70, 100},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 5,
	},
	"gargoyle": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           6,
		"radius":         15,
		"hp":             []int{100},
		"shield":         []int{100},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{20, 60, 90},
		"attackrange":    40,
		"attackinterval": 20,
		"preattackdelay": 5,
	},
	"giant": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           60,
		"radius":         55,
		"hp":             []int{1500},
		"sight":          350,
		"speed":          50,
		"targettypes":    Types{Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{500, 60, 90},
		"attackrange":    40,
		"attackinterval": 30,
		"preattackdelay": 8,
	},
	"legion": map[string]interface{}{
		"mass":           0,
		"radius":         50,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2000},
		"sight":          350,
		"speed":          800,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    350,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"transformdelay": 5,
		"skill":          "fireball",
	},
	"judge": map[string]interface{}{
		"mass":           0,
		"radius":         50,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2000},
		"sight":          350,
		"speed":          800,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    350,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"transformdelay": 5,
		"skill":          "bulletrain",
	},
	"nagmash": map[string]interface{}{
		"mass":           600,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2000},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{200},
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"skill":          "unload",
	},
	"astra": map[string]interface{}{
		"mass":           600,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2000},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{200},
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"skill":          "megalaser",
	},
	"psabu": map[string]interface{}{
		"type":           Troop,
		"layer":          Normal,
		"mass":           60,
		"radius":         40,
		"hp":             []int{2000},
		"shield":         []int{1000},
		"sight":          350,
		"speed":          50,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{300, 60, 90},
		"attackrange":    30,
		"attackinterval": 50,
		"attackradius":   80,
		"preattackdelay": 28,
	},
	"shadowvision": map[string]interface{}{
		"type":           Troop,
		"layer":          Ether,
		"mass":           20,
		"radius":         50,
		"hp":             []int{300},
		"shield":         300,
		"sight":          400,
		"speed":          80,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{300, 450, 600},
		"attackrange":    350,
		"attackinterval": 40,
		"preattackdelay": 0,
		"bulletlifetime": 30,
	},
}
