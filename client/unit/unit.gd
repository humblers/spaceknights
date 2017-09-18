extends Node2D

const UNIT_INFO = {
	"archer" : {
		"radius": 10,
		"sight" : 100,
		"range" : 100,
	},
	"barbarian" : {
		"radius": 13,
		"sight" : 100,
		"range" : 15,
	},
	"bomber" : {
		"radius": 10,
		"sight" : 100,
		"range" : 100,
	},
	"cannon" : {
		"radius": 20,
		"sight" : 100,
		"range" : 100,
	},
	"giant" : {
		"radius": 28,
		"sight" : 200,
		"range" : 15,
	},
	"megaminion" : {
		"radius": 20,
		"sight" : 80,
		"range" : 50,
	},
}

var unit_name setget set_unit_name

func _ready():
	input.connect("key_pressed", self, "toggle")

func toggle(key):
	if key == KEY_F1:
		debug.show_radius = not debug.show_radius
	elif key == KEY_F2:
		debug.show_sight = not debug.show_sight
	elif key == KEY_F3:
		debug.show_range = not debug.show_range
	update()

func _draw():
	if not unit_name or not UNIT_INFO.has(unit_name):
		return
	if debug.show_radius:
		draw_circle_arc(UNIT_INFO[unit_name]["radius"], Color(1.0, 0, 0))
	if debug.show_sight:
		draw_circle_arc(UNIT_INFO[unit_name]["sight"], Color(0, 1.0, 0))
	if debug.show_range:
		draw_circle_arc(UNIT_INFO[unit_name]["range"], Color(0, 0, 1.0))

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
