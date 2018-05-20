extends Node2D

const IMMUTABLE = 0
const WINGED = 1
const ARMED = 2

var velocity = Vector2(0, 0)

var u_name
var color
var target
var hp = 0
var shot_child_idx = 0
var damage_effect = Timer.new()

var effect_over
var effect_under

var hpnode
onready var body = get_node("Body")
onready var anim = get_node("AnimationPlayer")

signal position_changed(id, position)
signal projectile_created(type, target, lifetime, initial_position)
signal queued_free

func _ready():
	body.set_material(resource.unit_material.duplicate())
	clone_effect_nodes("EffectOver", effect_over)
	clone_effect_nodes("EffectUnder", effect_under)

func _process(delta):
	play_launch_effect(delta)

func initialize(unit):
	self.u_name = unit.Name
	self.color = "blue" if unit.Team == global.team else "red"
	set_hp()
	set_layers()
	set_damage_effect()
	debug.connect("option_changed", self, "update")

func set_position(pos):
	self.position = pos * 3
	emit_signal("position_changed", get_name(), self.position)

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
		anim.play(unit.State)
		var data = global.UNITS[u_name]
		if data.has("projectile"):
			match u_name:
				"archer":
					shot_child_idx += 1
					if shot_child_idx >= get_node("Body/Shotpoint").get_child_count():
						shot_child_idx = 0
					emit_signal("projectile_created",
							data.projectile,
							target,
							float(data.prehitdelay + 1) / global.SERVER_UPDATES_PER_SECOND,
							get_node("Body/Shotpoint").get_child(shot_child_idx).global_position)
				"freezer", "shuriken", "space_z":
					# not prepared
					pass
				_:
					emit_signal("projectile_created",
							data.projectile,
							target,
							float(data.prehitdelay + 1) / global.SERVER_UPDATES_PER_SECOND,
							find_node("Shotpoint").global_position)

	if unit.TransformStarted:
		if unit.Form == WINGED:
			anim.play_backwards("transform")
		elif unit.Form == ARMED:
			anim.play("transform")
	if unit.State == "move":
		var a = "move"
		match int(unit.Form):
			WINGED:
				a += "_winged"
			ARMED:
				a += "_armed"
		if anim.current_animation != a or not anim.is_playing():
			anim.play(a)
	if unit.State == "frozen":
		anim.stop()
		body.get_material().set_shader_param("frozen", true)
	else:
		body.get_material().set_shader_param("frozen", false)

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
	if global.team == "Home":
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

func find_child_nodes(root, mask, recursive=true, ret = []):
	for child in root.get_children():
		if mask in child.name:
			ret.append(child)
		if recursive:
			find_child_nodes(child, mask, recursive, ret)
	return ret

func clone_effect_nodes(org_node_name, dst):
	if dst == null:
		return
	var effects = []
	for node in find_child_nodes(self, org_node_name):
		effects += node.get_children()
	var paths = []
	for pos_node in effects:
		for effect_node in pos_node.get_children():
			var dup_node = effect_node.duplicate()
			dup_node.set_script(resource.effect_script.duplicate())
			dup_node.set_pos_node(pos_node)
			connect("queued_free", dup_node, "delete")
			dst.add_child(dup_node)
			paths.append( {
					"org_path" : get_path_to(effect_node),
					"dst_path" : dup_node.get_path(),
			} )
			effect_node.queue_free()
	clone_animations_for_effect(paths)

func clone_animations_for_effect(effect_paths):
	if effect_paths.size() <= 0:
		return
	var player = AnimationPlayer.new()
	for anim_name in anim.get_animation_list():
		var animation = anim.get_animation(anim_name).duplicate()
		for index in range(animation.get_track_count()):
			var track_path = String(animation.track_get_path(index))
			for path in effect_paths:
				var replaced = track_path.replace(path.org_path, path.dst_path)
				if replaced != track_path:
					animation.track_set_path(index, replaced)
					break
		player.add_animation(anim_name, animation)
	anim.queue_free()
	add_child(player)
	anim = player

func set_launch_effect(unit):
	pass

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

func transform_to_ui_node(pos=Vector2(0, 0), color=Color(1, 1, 1, 1)):
	set_position(pos)
	hpnode.hide()
	self.z_index = 0
	body.modulate = color

func delete():
	emit_signal("queued_free")
	queue_free()

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