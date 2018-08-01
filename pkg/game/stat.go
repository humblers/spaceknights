package game

var cards = map[string]map[string]interface{}{
	"archers": map[string]interface{}{
		"cost":    3000,
		"unit":    "archer",
		"count":   2,
		"offsetX": []int{-40, 40},
		"offsetY": []int{0, 0},
	},
	"fireball": map[string]interface{}{
		"cost":   4000,
		"caster": "legion",
		"damage": []int{300, 400, 500},
		"radius": 50,
	},
}

var units = map[string]map[string]interface{}{
	"archer": map[string]interface{}{
		"type":           Troop,
		"layer":          Ground,
		"mass":           6,
		"radius":         30,
		"hp":             []int{254},
		"sight":          800,
		"speed":          100,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Ground, Air},
		"attackdamage":   []int{100, 200, 300},
		"attackrange":    700,
		"attackinterval": 30,
		"preattackdelay": 0,
		"bulletlifetime": 20,
	},
	"legion": map[string]interface{}{
		"mass":           6,
		"radius":         50,
		"type":           Knight,
		"layer":          Ground,
		"hp":             []int{2000},
		"sight":          300,
		"speed":          3,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Ground, Air},
		"attackdamage":   []int{100},
		"attackrange":    300,
		"attackinterval": 40,
		"preattackdelay": 1,
		"bulletlifetime": 20,
		"transformdelay": 10,
		"skill":          "fireball",
	},
}
