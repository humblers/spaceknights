extends Node2D

var velocity = Vector2(0, 0)

var name
var color
var target
var state = "idle"
var hp = 0
var damage_effect = Timer.new()

var ignore_server = false
var elapsed = 0
var prev_pos

var hpnode
onready var body = get_node("Body")

signal position_changed(id, position)
signal projectile_created(type, target, lifetime, initial_position)

func _ready():
	if color == "blue" and global.is_knight(name):
		ignore_server = true
		prev_pos = get_pos()
		input.connect("mouse_dragged", self, "move")
		set_process(true)

func _process(delta):
	play_launch_effect(delta)
	elapsed += delta
	if ignore_server:
		update_knight_state()

func initialize(unit):
	self.name = unit.Name
	self.color = "blue" if unit.Team == global.team else "red"
	set_position(get_position(unit))
	set_base()
	set_hp(unit)
	set_layers()
	set_damage_effect()
	debug.connect("option_changed", self, "update")

func set_position(pos):
	set_pos(pos)
	emit_signal("position_changed", get_name(), pos)

func set_base():
	if has_node("Base"):
		var texture = resource.unit_base[name][color]
		get_node("Base").set_texture(texture)

func set_hp(unit):
	var path = "Hp"
	if name in ["maincore", "subcore"]:
		path = "Body/" + path
	hpnode = get_node(path)
	hpnode.get_node(color).show()
	hpnode.get_node(color).set_max(unit.Hp)
	if name in ["knightbullet", "scatteredbullet", "maincore", "subcore", "base"]:
		return
	if not hpnode.has_node("Label"):
		var label = Label.new()
		label.set_name("Label")
		label.set_text(str(unit.Hp))
		hpnode.add_child(label)

func set_layers():
	set_z(global.LAYERS[global.UNITS[name].layer])
	hpnode.set_z_as_relative(false)
	hpnode.set_z(global.LAYERS.UI)

func set_damage_effect():
	damage_effect.set_one_shot(true)
	damage_effect.connect("timeout", self, "hide_damage_effect")
	damage_effect.set_wait_time(0.15)
	add_child(damage_effect)

func update_changes(unit):
	body.set_rot(get_rotation(unit))
	update_hp(unit)
	set_target(unit)
	if unit.AttackStarted:
		body.set_frame(0)
		if global.UNITS[name].has("projectile"):
			emit_signal("projectile_created",
					global.UNITS[name].projectile,
					target,
					float(global.UNITS[name].prehitdelay + 1) / global.SERVER_UPDATES_PER_SECOND,
					get_node("Body/Shotpoint").get_global_pos())
	body.play("%s_%s" % [color, unit.State])
	if ignore_server:
		return
	set_position(get_position(unit))

func update_hp(unit):
	if unit.Hp <= 0:
		return
	if hp - global.dict_get(global.UNITS[name], "lifetimecost", 0) > unit.Hp:
		show_damage_effect()
	hp = unit.Hp
	hpnode.get_node(color).set_value(hp)
	if hpnode.has_node("Label"):
		hpnode.get_node("Label").set_text(str(unit.Hp))

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
	if global.team == "Home":
		return angle
	else:
		return angle + PI

func set_target(unit):
	if unit.has("TargetId"):
		target = unit.TargetId
		return
	if unit.has("TargetIds"):
		target = unit.TargetIds
		return
	target = null

func show_damage_effect():
	body.set_modulate(Color(1.0, 0.4, 0.4))
	damage_effect.start()

func hide_damage_effect():
	body.set_modulate(Color(1.0, 1.0, 1.0))

func set_launch_effect(unit):
	var launch_effect = resource.effect.launch.instance()
	launch_effect.set_name("Launch")
	body.add_child(launch_effect)
	var pos = get_position(unit)
	var destination = pos.y
	if global.team == unit.Team:
		pos.y = global.SCREEN_HEIGHT - global.UNITS[name].radius
		body.set_rot(PI)
		body.play("blue_idle")
	else:
		pos.y = global.MAP.height - global.SCREEN_HEIGHT + global.UNITS[name].radius
		body.play("red_idle")
	set_pos(pos)
	launch_effect.initialize(pos.y, destination, global.dict_get(global.UNITS[name], "size", "small"))
	hpnode.hide()
	body.set_self_opacity(0.7)
	set_process(true)

func play_launch_effect(delta):
	if not body.has_node("Launch"):
		return
	var launch_effect = body.get_node("Launch")
	if not launch_effect.is_finished(delta):
		set_pos(launch_effect.update_position(get_pos(), delta))
		return
	set_process(false)
	launch_effect.queue_free()
	hpnode.show()
	body.set_self_opacity(1.0)

func transform_to_guide_node(pos):
	set_pos(pos)
	hpnode.hide()
	body.set_opacity(0.5)

func set_ignore_server(b):
	ignore_server = b

func release_lock_on_anim(node):
	node.queue_free()

func move(rel_pos):
	if not ignore_server:
		return
	var pos = get_pos() + rel_pos
	var location = global.get_location(pos)
	if location == global.LOCATION_RED:
		pos.y = global.THRESHOLD_BLUE
	elif location == global.LOCATION_UI:
		pos.y = global.MAP.height
	set_position(pos)

func update_knight_state():
	var pos = get_pos()
	if elapsed > 0.5:
		if (prev_pos - pos).length() > 30:
			state = "move"
			get_node("Shield").show()
		elif state != "idle":
			state = "attack"
			get_node("Shield").hide()
		elapsed = 0
		prev_pos = pos
	if global.team == "Visitor":
		pos.y = global.MAP.height - pos.y
		pos.x = global.MAP.width - pos.x
	tcp.send({
		"State" : state,
		"Position" : { "X" : pos.x, "Y": pos.y },
	})

func _draw():
	var unit = global.UNITS[name]
	if debug.show_radius and unit.has("radius"):
		global.draw_circle_arc(unit["radius"], Color(1.0, 0, 0), self)
	if debug.show_sight and unit.has("sight"):
		global.draw_circle_arc(unit["sight"], Color(0, 1.0, 0), self)
	if debug.show_range and unit.has("range"):
		global.draw_circle_arc(unit["range"], Color(0, 0, 1.0), self)
	if debug.show_velocity and unit.has("radius"):
		var ahead = velocity.normalized() * (unit.radius + velocity.length())
		draw_line(Vector2(0, 0), ahead, Color(1.0, 1.0, 0))