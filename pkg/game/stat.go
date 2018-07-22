package game

var cost = map[string]int{
	"archers":  3000,
	"fireball": 4000,
}

var Archer = map[string]interface{}{
	"type":           Troop,
	"layer":          Ground,
	"mass":           6,
	"radius":         9,
	"hp":             []int{254},
	"sight":          100,
	"speed":          3,
	"attackrange":    70,
	"attackinterval": 15,
	"preattackdelay": 1,
	"bulletlifetime": 3,
	"damage":         []int{43, 53, 63},
	"targetlayers":   Layers{Ground, Air},
	"targettypes":    Types{Troop, Building, Knight},
}
