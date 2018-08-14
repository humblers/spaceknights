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
	"footmans": map[string]interface{}{
		"cost":    5000,
		"unit":    "archer",
		"count":   4,
		"offsetX": []int{-30, 30, -30, 30},
		"offsetY": []int{-30, -30, 30, 30},
	},
	"fireball": map[string]interface{}{
		"cost":   2000,
		"caster": "legion",
		"damage": []int{300, 400, 500},
		"radius": 70,
	},
	"unload": map[string]interface{}{
		"cost":         2000,
		"spawn":        "footmans",
		"caster":       "nagmash",
		"castduration": 100,
		"precastdelay": 52,
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
	"legion": map[string]interface{}{
		"mass":           6,
		"radius":         50,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2000},
		"sight":          350,
		"speed":          800,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    330,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"transformdelay": 5,
		"skill":          "fireball",
	},
	"nagmash": map[string]interface{}{
		"mass":           30,
		"radius":         80,
		"type":           Knight,
		"layer":          Normal,
		"hp":             []int{2000},
		"sight":          350,
		"speed":          100,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{50},
		"attackrange":    330,
		"attackinterval": 10,
		"preattackdelay": 0,
		"bulletlifetime": 10,
		"skill":          "unload",
	},
	"shadowvision": map[string]interface{}{
		"type":           Troop,
		"layer":          Ether,
		"mass":           20,
		"radius":         50,
		"hp":             []int{600},
		"shield":         300,
		"sight":          600,
		"speed":          80,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Normal},
		"attackdamage":   []int{100, 150, 200},
		"attackrange":    600,
		"attackinterval": 40,
		"preattackdelay": 0,
		"bulletlifetime": 30,
	},
}
