extends Node

const cost = {
	"archers": 3000,
	"fireball": 4000,
}

const archer = {
    "type":           "troop",
    "layer":          "ground",
    "mass":           6,
    "radius":         9,
    "hp":             [254],
    "sight":          100,
    "speed":          3,
    "attackrange":    70,
    "attackinterval": 15,
    "preattackdelay": 1,
    "bulletlifetime": 3,
    "damage":         [43, 53, 63],
    "targetlayers":   ["ground", "air"],
    "targettypes":    ["troop", "building", "knight"],
}