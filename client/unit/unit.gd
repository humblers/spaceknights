extends Node2D

const UNIT_INFO = {
	"archer" : {
		"radius": 10,
		"sight" : 100,
		"range" : 100,
		"projectile" : {
			"type": "bullet",
			"speed": 50,
			"mass": 5,
		},
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

var name setget name_set
var color setget color_set
var target setget target_set

func _ready():
	debug.connect("toggled", self, "update")

func _draw():
	if not name or not UNIT_INFO.has(name):
		return
	if debug.show_radius:
		draw_circle_arc(UNIT_INFO[name]["radius"], Color(1.0, 0, 0))
	if debug.show_sight:
		draw_circle_arc(UNIT_INFO[name]["sight"], Color(0, 1.0, 0))
	if debug.show_range:
		draw_circle_arc(UNIT_INFO[name]["range"], Color(0, 0, 1.0))

func draw_circle_arc(radius, color, center = Vector2(0, 0), angle_from = 0, angle_to = 360):
	var nb_points = 32
	var points_arc = Vector2Array()
	
	for i in range(nb_points+1):
		var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
		var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
		points_arc.push_back( point )

	for indexPoint in range(nb_points):
		draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color)

func anim_process():
	# do nothing on melee unit
	if not UNIT_INFO[name].has("projectile"):
		return

func name_set(_name):
	name = _name

func color_set(_color):
	color = _color
	#get_node(color).get_node("Animation").connect("frame_changed", self, "anim_process")

func target_set(_target):
	target = _target