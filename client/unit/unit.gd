extends Node2D

const UNIT_INFO = {
	"archer" : {
		"radius": 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : {
			"type": "bullet",
			"hitafter" : 9,
		},
	},
	"barbarian" : {
		"radius": 11,
		"sight" : 100,
		"range" : 15,
	},
	"bomber" : {
		"radius": 11,
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

var team
var name
var color setget set_color

var state
var target = null

signal create_projectile(pos, type, target, land_at)
signal to_projectile(is_dead, pos)

func _ready():
	debug.connect("toggled", self, "update")

func _draw():
	if not has_info():
		return
	if debug.show_radius:
		draw_circle_arc(UNIT_INFO[name]["radius"], Color(1.0, 0, 0))
	if debug.show_sight:
		draw_circle_arc(UNIT_INFO[name]["sight"], Color(0, 1.0, 0))
	if debug.show_range:
		draw_circle_arc(UNIT_INFO[name]["range"], Color(0, 0, 1.0))

func initialize(id, unit, my_team, unit_z, ui_z):
	set_name(id)
	team = unit.Team
	name = unit.Name
	set_color(my_team)
	set_z(unit_z)
	get_node("Hp").set_z(ui_z)
	set_layer_mask(0 if team == "Home" else 1)
	set_collision_mask(1 if team == "Home" else 0)

func process(unit, my_team, position):
	state = unit.State
	target = String(unit.TargetId) if unit.has("TargetId") else null
	var anim_node = get_anim_node()
	var rot = get_rotation(unit, my_team)
	anim_node.set_rot(rot)
	get_node("Collision").set_rot(rot)
	anim_node.play(state)
	get_node("Hp").get_node("Label").set_text(str(unit.Hp))
	set_pos(position)
	if state == "move":
		emit_signal("to_projectile", false, position)

func process_anim():
	if not is_range():
		return
	if not state == "attack":
		return
	if get_anim_node().get_frame() != 0:
		return
	var pos = get_pos()
	var projtype = UNIT_INFO[name]["projectile"]["type"]
	var hitafter = UNIT_INFO[name]["projectile"]["hitafter"]
	emit_signal("create_projectile", projtype, pos, target, hitafter)

func die():
	emit_signal("to_projectile", true, null)
	queue_free()

func has_info():
	return UNIT_INFO.has(name)

func is_range():
	return has_info() and UNIT_INFO[name].has("projectile")

func get_anim_node():
	return get_node(color).get_node("Animation")

func get_rotation(unit, my_team):
	var angle = atan2(unit.Heading.X, unit.Heading.Y)
	if my_team == "Home":
		return angle
	else:
		return angle + PI

func get_color(my_team):
	return "Blue" if team == my_team else "Red"

func set_color(my_team):
	color = get_color(my_team)
	for _color in ["Blue", "Red"]:
		if color != _color:
			get_node(_color).hide()
			continue
		get_node(_color).show()
		get_node(_color).get_node("Animation").show()
	get_anim_node().connect("frame_changed", self, "process_anim")

func draw_circle_arc(radius, color, center = Vector2(0, 0), angle_from = 0, angle_to = 360):
	var nb_points = 32
	var points_arc = Vector2Array()
	
	for i in range(nb_points+1):
		var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
		var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
		points_arc.push_back( point )

	for indexPoint in range(nb_points):
		draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color)