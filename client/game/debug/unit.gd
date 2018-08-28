extends Control

var radius = 0
var attack_range = 0

var unit
var game

func update(game, unit, debug_config):
	$Stats/Hp.visible = debug_config.get("Hp")
	$Stats/Hp/Label.text = "%d/%d" % [unit.hp, unit.initialHp()]
	if debug_config.get("Hp") and unit.get("shield"):
		$Stats/Shield.visible = true
		$Stats/Shield/Label.text = "%d/%d" % [unit.shield, unit.initialShield()]
	else:
		$Stats/Shield.visible = false
	$Stats/Radius.visible = debug_config.get("Radius")
	$Stats/Radius.modulate = debug_config.get("Radius_Color")
	radius = game.World().ToPixel(unit.Radius())
	$Stats/Radius/Label.text = String(radius)
	$Stats/AttackDamage.visible = debug_config.get("AttackDamage")
	$Stats/AttackDamage/Label.text = String(unit.attackDamage())
	$Stats/AttackInterval.visible = debug_config.get("AttackInterval")
	$Stats/AttackInterval/Label.text = String(unit.attackInterval())
	$Stats/AttackRange.visible = debug_config.get("AttackRange")
	$Stats/AttackRange.modulate = debug_config.get("AttackRange_Color")
	attack_range = game.World().ToPixel(unit.attackRange())
	$Stats/AttackRange/Label.text = String(attack_range)

func _draw():
	if $Stats/Radius.visible:
		draw_circle_arc(radius, $Stats/Radius.modulate)
	if $Stats/AttackRange.visible:
		draw_circle_arc(radius + attack_range, $Stats/AttackRange.modulate)


func draw_circle_arc(radius, color, center = Vector2(0, 0), angle_from = 0, angle_to = 360):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)