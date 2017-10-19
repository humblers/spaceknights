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
	play_launch_effect(delta)

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
	set_target_id(unit)
	set_hp(unit)
	if unit.State == "startattack":
		unit.State = "attack"
		body.set_animation("%s_attack" % color)
		if global.UNITS[name].has("projectile"):
			emit_signal("projectile_created",
					global.UNITS[name].projectile,
					target_id,
					float(global.UNITS[name].prehitdelay + 1) / global.SERVER_UPDATES_PER_SECOND,
					get_node("Body/Shotpoint").get_global_pos())
	body.play("%s_%s" % [color, unit.State])

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
	target_id = global.dict_get(unit, "TargetId", 0)

func show_damage_effect():
	body.set_modulate(Color(1.0, 0.4, 0.4))
	damage_effect.start()

func hide_damage_effect():
	body.set_modulate(Color(1.0, 1.0, 1.0))

func set_launch_effect(unit):
	var launch_effect = load("res://effect/launch.tscn").instance()
	launch_effect.set_name("Launch")
	body.add_child(launch_effect)
	var pos = get_position(unit)
	var destination = pos.y
	if global.team == unit.Team:
		pos.y = global.MAP.height - global.MOTHERSHIP_BASE_HEIGHT
		body.set_rot(PI)
		body.play("blue_idle")
	else:
		pos.y = global.MOTHERSHIP_BASE_HEIGHT
		body.play("red_idle")
	set_pos(pos)
	launch_effect.initialize(pos.y, destination, global.dict_get(global.UNITS[name], "size", "small"))
	get_node("Hp").hide()
	body.set_self_opacity(0.7)

func play_launch_effect(delta):
	if not body.has_node("Launch"):
		return
	var launch_effect = body.get_node("Launch")
	if not launch_effect.is_finished(delta):
		set_pos(launch_effect.update_position(get_pos(), delta))
		return
	launch_effect.queue_free()
	get_node("Hp").show()
	body.set_self_opacity(1.0)

func transform_to_guide_node(pos):
	set_pos(pos)
	get_node("Hp").hide()
	body.set_opacity(0.5)

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