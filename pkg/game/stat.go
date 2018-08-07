package game

var cards = map[string]map[string]interface{}{
	"archers": map[string]interface{}{
		"cost":    1000,
		"unit":    "archer",
		"count":   2,
		"offsetX": []int{-40, 40},
		"offsetY": []int{0, 0},
	},
	"fireball": map[string]interface{}{
		"cost":   2000,
		"caster": "legion",
		"damage": []int{300, 400, 500},
		"radius": 70,
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
		"targetlayers":   Layers{Normal, Ether},
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
		"targetlayers":   Layers{Normal, Ether},
		"attackdamage":   []int{50},
		"attackrange":    330,
		"attackinterval": 2,
		"preattackdelay": 1,
		"bulletlifetime": 10,
		"transformdelay": 5,
		"skill":          "fireball",
	},
}
