extends Node2D

var velocity = Vector2(0, 0)

var u_name
var color
var target
var hp = 0
var damage_effect = Timer.new()

var hpnode
onready var body = get_node("Body")
onready var anim = get_node("Anim")

signal position_changed(id, position)
signal projectile_created(type, target, lifetime, initial_position)

func _ready():
	body.set_material(resource.unit_material.duplicate())

func _process(delta):
	play_launch_effect(delta)

func initialize(unit):
	self.u_name = unit.Name
	self.color = "blue" if unit.Team == global.team else "red"
	set_base()
	set_hp()
	set_layers()
	set_damage_effect()
	debug.connect("option_changed", self, "update")

func set_position(pos):
	self.position = pos * 3
	emit_signal("position_changed", get_name(), self.position)

func set_base():
	if has_node("Base"):
		var texture = resource.unit_base[u_name][color]
		get_node("Base").set_texture(texture)

func set_hp():
	var path = "Hp"
	if u_name in ["maincore", "subcore"]:
		path = "Body/" + path
	hpnode = get_node(path)
	hpnode.get_node(color).show()
	hpnode.get_node(color).set_max(global.dict_get(global.UNITS[u_name], "hp", 100))

func set_layers():
	self.z_index = global.LAYERS[global.UNITS[u_name].layer]
	hpnode.z_as_relative = false
	hpnode.z_index = global.LAYERS.UI

func set_damage_effect():
	damage_effect.set_one_shot(true)
	damage_effect.connect("timeout", self, "hide_damage_effect")
	damage_effect.set_wait_time(0.15)
	add_child(damage_effect)

func update_changes(unit):
	set_position(get_position(unit))
	body.rotation = get_rotation(unit)
	set_target(unit)
	update_hp(unit)
	if unit.AttackStarted:
		body.set_frame(0)
		if global.UNITS[u_name].has("projectile"):
			emit_signal("projectile_created",
					global.UNITS[u_name].projectile,
					target,
					float(global.UNITS[u_name].prehitdelay + 1) / global.SERVER_UPDATES_PER_SECOND,
					get_node("Body/Shotpoint").global_position)
	if unit.State == "frozen":
		anim.stop()
		body.get_material().set_shader_param("frozen", true)
	else:
		body.get_material().set_shader_param("frozen", false)
		anim.play(unit.State)

func update_hp(unit):
	if unit.Hp <= 0:
		return
	if hp - global.dict_get(global.UNITS[u_name], "lifetimecost", 0) > unit.Hp:
		show_damage_effect()
	hp = unit.Hp
	hpnode.get_node(color).set_value(hp)

func get_velocity(unit):
	var x = unit.Velocity.X
	var y = unit.Velocity.Y
	if global.team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(-x, -y)
		
func get_position(unit):
	var x = unit.Position.X
	var y = unit.Position.Y
	if global.team == "Home":
		return Vector2(x, y)
	else:
		return Vector2(global.MAP.width - x, global.MAP.height - y)

func get_rotation(unit):
	var angle = atan2(unit.Heading.X, unit.Heading.Y)
	if global.team == "Visitor":
		angle += PI
	return -angle

func set_target(unit):
	if unit.has("TargetId"):
		target = unit.TargetId
		return
	if unit.has("TargetIds"):
		target = unit.TargetIds
		return
	target = null

func show_damage_effect():
	body.get_material().set_shader_param("damaged", true)
	damage_effect.start()

func hide_damage_effect():
	body.get_material().set_shader_param("damaged", false)

func set_launch_effect(unit):
	var launch_effect = resource.effect.launch.instance()
	launch_effect.set_name("Launch")
	body.add_child(launch_effect)
	var pos = get_position(unit)
	var destination = pos.y
	if global.team == unit.Team:
		pos.y = global.SCREEN_HEIGHT - global.UNITS[u_name].radius
		body.rotation = PI
		body.play("blue_idle")
	else:
		pos.y = global.MAP.height - global.SCREEN_HEIGHT + global.UNITS[u_name].radius
		body.play("red_idle")
	set_position(pos)
	launch_effect.initialize(pos.y, destination, global.dict_get(global.UNITS[u_name], "size", "small"))
	hpnode.hide()
	body.self_modulate = Color(1, 1, 1, 0.7)
	set_process(true)

func play_launch_effect(delta):
	if not body.has_node("Launch"):
		return
	var launch_effect = body.get_node("Launch")
	if not launch_effect.is_finished(delta):
		set_position(launch_effect.update_position(position, delta))
		return
	set_process(false)
	launch_effect.queue_free()
	hpnode.show()
	body.self_modulate = Color(1, 1, 1, 1.0)

func transform_to_guide_node(pos):
	set_position(pos)
	hpnode.hide()
	body.modulate = Color(1, 1, 1, 0.5)

func release_lock_on_anim(node):
	node.queue_free()

func _draw():
	var unit = global.UNITS[u_name]
	if debug.show_radius and unit.has("radius"):
		global.draw_circle_arc(unit["radius"], Color(1.0, 0, 0), self)
	if debug.show_sight and unit.has("sight"):
		global.draw_circle_arc(unit["sight"], Color(0, 1.0, 0), self)
	if debug.show_range and unit.has("range"):
		global.draw_circle_arc(unit["range"], Color(0, 0, 1.0), self)
	if debug.show_velocity and unit.has("radius"):
		var ahead = velocity.normalized() * (unit.radius + velocity.length())
		draw_line(Vector2(0, 0), ahead, Color(1.0, 1.0, 0))