extends "res://game/unit/berserker/berserker.gd"

func findTarget():
	var t = game.FindGiantGargoyle()
	if t != null:
		return t
	return .findTarget()