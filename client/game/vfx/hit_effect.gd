tool
extends Node2D

enum SHAPE {RECT, CIRCLE}
export(SHAPE) var type

export(Rect2) var rect_area

export(float) var circle_radius

func hit(attacker):
	var name = attacker.get("name_")
	if name != null and stat.units[name]["attacktype"] == stat.Laser:
		return
	if attacker.name.find("Missile") >= 0:
		return
	var pos = Vector2(0, 0)
	match type:
		SHAPE.RECT:
			pos.x = rand_range(rect_area.position.x, rect_area.end.x)
			pos.y = rand_range(rect_area.position.y, rect_area.end.y)
		SHAPE.CIRCLE:
			var angle = rand_range(-PI, PI)
			var radius = rand_range(0, circle_radius)
			pos.x = cos(angle) * radius
			pos.y = sin(angle) * radius
	$HitPosition.position = pos
	$AnimationPlayer.play("hit")

func _draw():
	if not Engine.editor_hint:
		return
	match type:
		SHAPE.RECT:
			draw_rect(rect_area, Color(0, 1, 0), false)
		SHAPE.CIRCLE:
			draw_circle_arc(circle_radius, Color(0, 1, 0))

func draw_circle_arc(radius, color, center = Vector2(0, 0), angle_from = 0, angle_to = 360):
	var nb_points = 32
	var points_arc = PoolVector2Array()
	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)