package game

var cards = map[string]map[string]interface{}{
	"archers": map[string]interface{}{
		"cost":    3000,
		"unit":    "archer",
		"count":   2,
		"offsetX": []int{-5, 5},
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
		"radius":         9,
		"hp":             []int{254},
		"sight":          100,
		"speed":          3,
		"targettypes":    Types{Troop, Building, Knight},
		"targetlayers":   Layers{Ground, Air},
		"attackdamage":   []int{43, 53, 63},
		"attackrange":    70,
		"attackinterval": 15,
		"preattackdelay": 0,
		"bulletlifetime": 3,
	},
	"legion": map[string]interface{}{
		"mass":           6,
		"radius":         9,
		"type":           Troop,
		"layer":          Ground,
		"hp":             []int{2000},
		"sight":          100,
		"speed":          3,
		"targettypes":    Types{Troop},
		"targetlayers":   Layers{Ground, Air},
		"attackdamage":   []int{50},
		"attackrange":    70,
		"attackinterval": 15,
		"preattackdelay": 1,
		"bulletlifetime": 3,
		"transformdelay": 10,
		"skill":          "fireball",
	},
}
