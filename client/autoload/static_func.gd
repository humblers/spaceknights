extends Node

static func dict_get(dict, key, default):
	if dict.has(key):
		return dict[key]
	return default
	
static func draw_circle_arc(cavas_item, center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points+1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	for index_point in range(nb_points):
		cavas_item.draw_line(points_arc[index_point], points_arc[index_point + 1], color)
