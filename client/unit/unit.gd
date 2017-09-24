extends Node2D

const UNIT_INFO = {
	"archer" : {
		"radius": 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : {
			"type": "bullet",
			"lifetime" : 6, # server's unit prehitdelay
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
		"projectile" : {
			"type" : "bullet",
			"lifetime" : 5,
		},
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
	"minipekka" : {
		"radius": 12,
		"sight" : 100,
		"range" : 15,
	},
	"musketeer" : {
		"radius": 11,
		"sight" : 120,
		"range" : 120,
		"projectile" : {
			"type" : "bullet",
			"lifetime" : 10,
		},
	},
	"pekka" : {
		"radius": 13,
		"sight" : 100,
		"range" : 15,
	},
	"skeleton" : {
		"radius": 6,
		"sight" : 100,
		"range" : 5,
	},
	"speargoblin" : {
		"radius": 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : {
			"type" : "bullet",
			"lifetime" : 12,
		},
	},
	"valkyrie" : {
		"radius": 12,
		"sight" : 100,
		"range" : 20,
	},
}

var modulate_timer = Timer.new()

var team
var name
var color setget set_color

var state
var target_id = 0

signal create_projectile(target_id, type, pos, lifetime)
signal send_posistion(pos)

func _ready():
	debug.connect("toggled", self, "update")
	modulate_timer.set_one_shot(true)
	modulate_timer.connect("timeout", self, "erase_modulate")
	add_child(modulate_timer)

func _draw():
	if not has_info():
		return
	if debug.show_radius:
		draw_circle_arc(UNIT_INFO[name]["radius"], Color(1.0, 0, 0))
	if debug.show_sight:
		draw_circle_arc(UNIT_INFO[name]["sight"], Color(0, 1.0, 0))
	if debug.show_range:
		draw_circle_arc(UNIT_INFO[name]["range"], Color(0, 0, 1.0))

func initialize(id, unit, user_team, unit_z, ui_z):
	set_name(id)
	team = unit.Team
	name = unit.Name
	set_color(user_team)
	set_z(unit_z)
	get_node("Hp").set_z(ui_z)
	set_layer_mask(0 if team == "Home" else 1)
	set_collision_mask(1 if team == "Home" else 0)

func process(unit, user_team, position):
	state = unit.State
	target_id = unit.TargetId
	var rot = get_rotation(unit, user_team)
	get_node(color).set_rot(rot)
	get_node("Collision").set_rot(rot)
	if is_range():
		get_anim_node().get_node("Shotpoint").set_rot(rot)
	get_anim_node().play(state)
	get_node("Hp").get_node("Label").set_text(str(unit.Hp))
	set_pos(position)
	emit_signal("send_posistion", position)

func process_anim():
	if state != "attack":
		return
	if not is_range():
		return
	if get_anim_node().get_frame() != 0:
		return
	emit_signal("create_projectile", 
		target_id, 
		UNIT_INFO[name]["projectile"]["type"], 
		get_anim_node().get_node("Shotpoint").get_global_pos(),
		UNIT_INFO[name]["projectile"]["lifetime"])

func damage_modulate():
	get_anim_node().set_modulate(Color(1.0, 0.4, 0.4))
	modulate_timer.set_wait_time(0.15)
	modulate_timer.start()

func erase_modulate():
	get_anim_node().set_modulate(Color(1.0, 1.0, 1.0))

func has_info():
	return UNIT_INFO.has(name)

func is_range():
	return has_info() and UNIT_INFO[name].has("projectile")

func get_anim_node():
	return get_node(color).get_node("Animation")

func get_rotation(unit, user_team):
	var angle = atan2(unit.Heading.X, unit.Heading.Y)
	if user_team == "Home":
		return angle
	else:
		return angle + PI

func set_color(user_team):
	var off_color = "Red" if team == user_team else "Blue"
	get_node(off_color).hide()
	color = "Blue" if team == user_team else "Red"
	get_node(color).show()
	get_anim_node().show()
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