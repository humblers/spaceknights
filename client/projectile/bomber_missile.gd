extends Node

const MISSILE_WAYPOINT_DISTANCE = 50
const ANIM_NAME = "waypoints"

export var damage_radius = 0

onready var anim = Animation.new()
onready var player = AnimationPlayer.new()
onready var explosion = get_node("Explosion")
onready var missiles = get_node("Missiles")

var starting_position
var target_position
var lifetime
var elapsed = 0

func _ready():
	set_missile_animation_player()
	set_missile_animation_track()
	play_missile_animation()

func initialize(target, lifetime, position):
	self.lifetime = lifetime
	starting_position = position
	target_position = target.get_pos()
	target.connect("position_changed", self, "update_target_position")

func set_missile_animation_player():
	player.add_animation(ANIM_NAME, anim)
	player.set_current_animation(ANIM_NAME)
	anim.set_length(lifetime)
	anim.set_step(1.0 / global.SERVER_UPDATES_PER_SECOND)
	player.connect("finished", self, "missile_explode")
	add_child(player)

func play_missile_animation():
	player.play(ANIM_NAME)

func set_missile_animation_track():
	var start_offset = rand_range(0, 0.4)
	var direction = (target_position - starting_position).normalized()
	var children = missiles.get_children()
	for i in range(children.size()):
		var child = children[i]
		var path = child.get_path()
		var pos_offset = float(children.size() - 1) / 2 - i
		start_offset = abs(start_offset - 0.1 * i)
		child.set_z(global.LAYERS.Projectile)

		var waypoints = []
		var rotations = []

		# set waypoint position
		var pos_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(pos_track, "%s:transform/pos" % path)
#		anim.track_set_interpolation_type(pos_track, Animation.INTERPOLATION_CUBIC)
		waypoints.append(starting_position)
		waypoints.append(starting_position + direction.rotated(PI / 2) * MISSILE_WAYPOINT_DISTANCE / 5 * pos_offset)
		waypoints.append(starting_position + direction.rotated(PI / 2).rotated(rand_range(-PI / 12, PI / 12)) * MISSILE_WAYPOINT_DISTANCE / 3 * pos_offset)
		var middle_point = starting_position + direction * starting_position.distance_to(target_position) / 2
		middle_point = middle_point + direction.rotated(PI / 2) * MISSILE_WAYPOINT_DISTANCE * pos_offset
		waypoints.append(middle_point)
		waypoints.append(target_position - direction.rotated(- PI / 4 * 3 + PI * 2 / children.size() * i) * damage_radius * rand_range(0.7, 1))
		waypoints.append(target_position - direction.rotated(- PI / 4 * 3 + PI * 2 / children.size() * i) * damage_radius / 2)
		var prev_point
		for j in range(waypoints.size()):
			var waypoint = waypoints[j]
			anim.track_insert_key(pos_track, min(lifetime, lifetime / waypoints.size() * j + start_offset), waypoint)
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
			anim.track_insert_key(rot_track, min(lifetime, lifetime / rotations.size() * j + start_offset), rad2deg(rotation))
			prev_rot = rotation

		var visible_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(visible_track, "%s:visibility/visible" % path)
		anim.track_insert_key(visible_track, 0, false)
		anim.track_insert_key(visible_track, start_offset, true)

func update_target_position(position):
	target_position = position
	var direction = (target_position - starting_position).normalized()
	explosion.set_pos(target_position)
	if not player or not anim:
		return
	if not player.is_playing():
		return
	var children = missiles.get_children()
	for i in range(children.size()):
		var track = anim.find_track("%s:transform/pos" % children[i].get_path())
		anim.track_insert_key(track, lifetime, target_position - direction.rotated(- PI / 4 * 3 + PI * 2 / children.size() * i) * damage_radius / 2)

func missile_explode():
	missiles.queue_free()
	explosion.connect("finished", self, "on_finished")
	explosion.show()
	explosion.play()

func on_finished():
	queue_free()