extends Node

const ANIM_NAME = "waypoints"

export var name = ""
export var missile_spread = 10
export var spread_divider_on_way1 = 5
export var spread_divider_on_way2 = 3
export var damage_radius = 0

var starting_position
var target_position
var lifetime

var deploy_offset = rand_range(0, 0.4)
var anim = Animation.new()
var player = AnimationPlayer.new()

onready var missiles = get_node("Missiles")

func _ready():
	set_animation_player()
	set_animation_track()
	play()

func initialize(target, lifetime, position):
	self.lifetime = lifetime
	starting_position = position
	target_position = target.get_pos()
	target.connect("position_changed", self, "update_target_position")

func set_animation_player():
	player.add_animation(ANIM_NAME, anim)
	player.set_current_animation(ANIM_NAME)
	anim.set_length(lifetime)
	anim.set_step(1.0 / global.SERVER_UPDATES_PER_SECOND)
	add_child(player)

func play():
	player.play(ANIM_NAME)
	yield(player, "finished")
	var explosion
	for missile in missiles.get_children():
		explosion = load("res://effect/explosion/missile.tscn").instance()
		explosion.initialize(name, missile.get_pos())
		add_child(explosion)
		missile.queue_free()
	yield(explosion, "finished")
	queue_free()

func set_animation_track():
	var direction = (target_position - starting_position).normalized()
	var children = missiles.get_children()
	for i in range(children.size()):
		var child = children[i]
		var path = child.get_path()
		var pos_offset
		if children.size() == 1:
			pos_offset = -1 if randi() % 2 == 0 else 1
		else:
			pos_offset = float(children.size() - 1) / 2 - i
		var delay = abs(deploy_offset - 0.1 * i)
		child.set_z(global.LAYERS.Projectile)

		var waypoints = []
		var rotations = []

		# set waypoint position
		var pos_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(pos_track, "%s:transform/pos" % path)
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
		anim.track_set_path(rot_track, "%s:transform/rot" % path)
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
		anim.track_set_path(visible_track, "%s:visibility/visible" % path)
		anim.track_insert_key(visible_track, delay, true)

func update_target_position(position):
	target_position = position
	if not player or not anim:
		return
	if not player.is_playing():
		return
	var direction = (target_position - starting_position).normalized()
	var children = missiles.get_children()
	for i in range(children.size()):
		var track = anim.find_track("%s:transform/pos" % children[i].get_path())
		anim.track_insert_key(track, lifetime,
				target_position
				+ direction.rotated(-PI / children.size() * (2 * i + 1))
				* damage_radius / 2)