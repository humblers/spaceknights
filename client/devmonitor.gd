extends Node2D

const UNIT_INFO = {
	"archer" : {
		"sight" : 100,
		"range" : 100,
	},
	"barbarian" : {
		"sight" : 100,
		"range" : 15,
	},
	"cannon" : {
		"sight" : 100,
		"range" : 100,
	},
	"giant" : {
		"sight" : 200,
		"range" : 15,
	},
	"megaminion" : {
		"sight" : 80,
		"range" : 50,
	},
}

var unit_name setget set_unit_name

func _ready():
	pass

func _draw():
	if not OS.is_debug_build():
		return
	if not unit_name or not UNIT_INFO.has(unit_name):
		return
	draw_circle_arc(UNIT_INFO[unit_name]["sight"], Color(0, 1.0, 0))
	draw_circle_arc(UNIT_INFO[unit_name]["range"], Color(1.0, 0, 0))

func draw_circle_arc(radius, color, center = Vector2(0, 0), angle_from = 0, angle_to = 360):
	var nb_points = 32
	var points_arc = Vector2Array()
	
	for i in range(nb_points+1):
		var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
		var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
		points_arc.push_back( point )

	for indexPoint in range(nb_points):
		draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color)

func set_unit_name(name):
	unit_name = name