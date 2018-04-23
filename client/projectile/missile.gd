extends Node

const ANIM_NAME = "waypoints"

export var m_name = ""
export var missile_spread = 10
export var spread_divider_on_way1 = 5
export var spread_divider_on_way2 = 3
export var damage_radius = 0

var is_multi_target
var starting_position
var target_positions = []
var lifetime

var deploy_offset = rand_range(0, 0.4)
var anim = Animation.new()
var player = AnimationPlayer.new()

onready var missiles = get_node("Missiles")

func _ready():
	set_animation_player()
	set_animation_track()
	play()

func set_single_target(target, lifetime, position):
	self.lifetime = lifetime
	is_multi_target = false
	starting_position = position
	target_positions.append([target.get_name(), target.position])
	target.connect("position_changed", self, "update_target_position")

func set_multi_target(target, lifetime, position):
	self.lifetime = lifetime
	is_multi_target = true
	starting_position = position
	for node in target:
		target_positions.append([node.get_name(), node.postiion])
		node.connect("position_changed", self, "update_target_position")
	target_positions.sort_custom(self, "sort_x_order")

func sort_x_order(a, b):
	if a[1].x < b[1].x:
		return true
	return false

func set_animation_player():
	player.add_animation(ANIM_NAME, anim)
	player.set_current_animation(ANIM_NAME)
	anim.set_length(lifetime)
	anim.set_step(1.0 / global.SERVER_UPDATES_PER_SECOND)
	add_child(player)

func play():
	player.play(ANIM_NAME)
	yield(player, "animation_finished")
	var explosion
	for missile in missiles.get_children():
		explosion = resource.effect.explosion.missile.instance()
		explosion.initialize(m_name, missile.position)
		add_child(explosion)
		missile.queue_free()
	yield(explosion, "animation_finished")
	queue_free()

func set_animation_track():
	var children = missiles.get_children()
	var size_factor = target_positions.size() if is_multi_target else children.size()
	var target_position = target_positions[0][1]
	for i in range(children.size()):
		var child = children[i]
		if is_multi_target:
			if target_positions.size() - 1 < i:
				return
			target_position = target_positions[i][1]
		var direction = (target_position - starting_position).normalized()
		var path = child.get_path()
		var pos_offset
		if target_positions.size() == 1:
			pos_offset = -1 if randi() % 2 == 0 else 1
		else:
			pos_offset = float(target_positions.size() - 1) / 2 - i
		var delay = abs(deploy_offset - 0.1 * i)
		child.z_index = global.LAYERS.Projectile

		var waypoints = []
		var rotations = []

		# set waypoint position
		var pos_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(pos_track, "%s:position" % path)
		waypoints.append(starting_position)
		waypoints.append(
				starting_position
				+ direction.rotated(-PI / 2)
				* missile_spread / spread_divider_on_way1
				* pos_offset)
		waypoints.append(
				starting_position
				+ direction.rotated(-PI / 2).rotated(rand_range(-PI / 12, PI / 12))
				* missile_spread / spread_divider_on_way2
				* pos_offset)
		waypoints.append(
				starting_position
				+ direction
				* starting_position.distance_to(target_position) / 2
				+ direction.rotated(-PI / 2)
				* missile_spread
				* pos_offset)
		waypoints.append(
				target_position
				+ direction.rotated(-PI / children.size() * (2 * i + 1))
				* damage_radius / 2)
		var prev_point
		for j in range(waypoints.size()):
			var waypoint = waypoints[j]
			anim.track_insert_key(pos_track,
					min(lifetime, lifetime / (waypoints.size() - 1) * j + delay),
					waypoint)
			if prev_point == null:
				prev_point = waypoint
				continue
			rotations.append((waypoint - prev_point).angle())
			prev_point = waypoint

		# set waypoint rotation
		var rot_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(rot_track, "%s:rotation_degrees" % path)
		var prev_rot
		for j in range(rotations.size()):
			var rotation = rotations[j]
			if prev_rot != null and abs(rotation - prev_rot) > PI:
				if rotation < 0:
					rotation += PI * 2
				else:
					rotation -= PI * 2
			anim.track_insert_key(rot_track,
					min(lifetime, lifetime / (rotations.size() - 1) * j + delay),
					rad2deg(rotation))
			prev_rot = rotation

		# set missile visible delay
		var visible_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(visible_track, "%s:visible" % path)
		anim.track_insert_key(visible_track, delay, true)

func update_target_position(id, position):
	if not player or not anim:
		return
	if not player.is_playing():
		return
	for info in target_positions:
		if str(info[0]) == str(id):
			info[1] = position
	var children = missiles.get_children()
	var target_position = target_positions[0][1]
	for i in range(children.size()):
		var child = children[i]
		if is_multi_target:
			if target_positions.size() - 1 < i:
				return
			target_position = target_positions[i][1]
		var direction = (target_position - starting_position).normalized()
		var track = anim.find_track("%s:position" % child.get_path())
		anim.track_insert_key(track, lifetime,
				target_position)