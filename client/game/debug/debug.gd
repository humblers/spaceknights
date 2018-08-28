extends Node

export var Enable = false

export var Hp = false

export var Radius = false
export var Radius_Color = Color(0, 1.0, 0, 1)

export var AttackDamage = false

export var AttackInterval = false

export var AttackRange = false
export var AttackRange_Color = Color(1.0, 1.0, 0, 1)

func _unhandled_key_input(ev):
	if not ev.pressed:
		return
	match ev.scancode:
		KEY_F1:
			Hp = not Hp
		KEY_F2:
			Radius = not Radius
		KEY_F3:
			AttackDamage = not AttackDamage
		KEY_F4:
			AttackInterval = not AttackInterval
		KEY_F5:
			AttackRange = not AttackRange

func update(game):
	if not Enable:
		return
	for id in game.units:
		var unit = game.units[id]
		if not unit.has_node("debug"):
			var debug_stat = preload("res://game/debug/unit.tscn").instance()
			unit.add_child(debug_stat)
		unit.get_node("debug").update(game, unit, self)