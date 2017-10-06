extends Node2D

var name
var color
var target_id = 0
var hp = 0
var damage_effect = Timer.new()
onready var body = get_node("Body")

signal position_changed(position)
signal projectile_created(type, target_id, lifetime, initial_position)

func _ready():
	set_process(true)

func _process(delta):
	if body.get_animation() == "%s_attack" % color and body.get_frame() == 0:
		if not global.UNITS[name].has("projectile"):
			return
		emit_signal("projectile_created",
				global.UNITS[name].projectile,
				target_id,
				float(global.UNITS[name].prehitdelay + 1) / global.SERVER_UPDATES_PER_SECOND,
				get_node("Body/Shotpoint").get_global_pos())

func initialize(unit):
	self.name = unit.Name
	self.color = "blue" if unit.Team == global.team else "red"
	set_base()
	set_layers()
	set_damage_effect()
	debug.connect("option_changed", self, "update")

func set_base():
	if has_node("Base"):
		var texture = load("res://unit/%s/%s_base.png" % [name, color])
		get_node("Base").set_texture(texture)

func set_layers():
	set_z(global.LAYERS[global.UNITS[name].layer])
	get_node("Hp").set_z_as_relative(false)
	get_node("Hp").set_z(global.LAYERS.UI)

func set_damage_effect():
	damage_effect.set_one_shot(true)
	damage_effect.connect("timeout", self, "hide_damage_effect")
	damage_effect.set_wait_time(0.15)
	add_child(damage_effect)

func update_changes(unit):
	set_pos(get_position(unit))
	emit_signal("position_changed", get_pos())
	body.set_rot(get_rotation(unit))
	body.play(color + "_" + unit.State)
	set_target_id(unit)
	set_hp(unit)

func set_hp(unit):
	if hp - global.dict_get(global.UNITS[name], "lifetimecost", 0) > unit.Hp:
		show_damage_effect()
	hp = unit.Hp
	get_node("Hp/Label").set_text(str(hp))

func get_position(unit):
	var x = unit.Position.X
	var y = unit.Position.Y
	if global.team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(global.MAP.width - x, global.MAP.height - y)

func get_rotation(unit):
	var angle = atan2(unit.Heading.X, unit.Heading.Y)
	if global.team == "Home":
		return angle
	else:
		return angle + PI

func set_target_id(unit):
	if unit.has("TargetId"):
		target_id = unit.TargetId
	else:
		target_id = 0

func show_damage_effect():
	body.set_modulate(Color(1.0, 0.4, 0.4))
	damage_effect.start()

func hide_damage_effect():
	body.set_modulate(Color(1.0, 1.0, 1.0))

func _draw():
	var unit = global.UNITS[name]
	if debug.show_radius and unit.has("radius"):
		draw_circle_arc(unit["radius"], Color(1.0, 0, 0))
	if debug.show_sight and unit.has("sight"):
		draw_circle_arc(unit["sight"], Color(0, 1.0, 0))
	if debug.show_range and unit.has("range"):
		draw_circle_arc(unit["range"], Color(0, 0, 1.0))

func draw_circle_arc(radius, color, center = Vector2(0, 0), angle_from = 0, angle_to = 360):
	var nb_points = 32
	var points_arc = Vector2Array()
	
	for i in range(nb_points+1):
		var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
		var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
		points_arc.push_back( point )

	for indexPoint in range(nb_points):
		draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color)