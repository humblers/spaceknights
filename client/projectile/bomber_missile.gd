extends Node

const MISSILE_WAYPOINT_DISTANCE = 30

onready var missiles = get_node("Missiles")
onready var explosion = get_node("Explosion")

var player
var anim

var starting_position
var target_position
var target_radius
var lifetime
var elapsed = 0

func _ready():
	set_missile_animation_player()
	set_missile_waypoints()
	play_missile_animation()

func initialize(target, lifetime, position):
	self.lifetime = lifetime
	starting_position = position
	target_position = target.get_pos()
	target_radius = global.UNITS[target.name].radius
	target.connect("position_changed", self, "update_target_position")

func set_missile_animation_player():
	player = AnimationPlayer.new()
	anim = Animation.new()
	player.add_animation("waypoints", anim)	
	player.set_current_animation("waypoints")
	anim.set_length(lifetime)
	anim.set_step(0.1)
	player.connect("finished", self, "missile_explode")
	add_child(player)

func play_missile_animation():
	missiles.show()
	player.play("waypoints")

func set_missile_waypoints():
	var position = starting_position
	var direction = (target_position - position).normalized()
	var last_waypoint = target_position - direction * target_radius
	var children = missiles.get_children()
	for i in range(children.size()):
		var child = children[i]
		child.set_z(global.LAYERS.Projectile)
		var adjust = float(children.size() - 1) / 2 - i

		var pos_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(pos_track, "%s:transform/pos" % child.get_path())
		var first_waypoint = position + direction.rotated(PI / 2) * MISSILE_WAYPOINT_DISTANCE / 3 * adjust
		var second_waypoint = position + direction.rotated(PI / 2).rotated(rand_range(-PI / 12, PI / 12)) * MISSILE_WAYPOINT_DISTANCE * adjust
		anim.track_insert_key(pos_track, lifetime / 3 * 0, position)
		anim.track_insert_key(pos_track, lifetime / 3 * 1, first_waypoint)
		anim.track_insert_key(pos_track, lifetime / 3 * 2, second_waypoint)
		anim.track_insert_key(pos_track, lifetime / 3 * 3, last_waypoint)

		var rot_track = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(rot_track, "%s:transform/rot" % child.get_path())
		var first_rotate = (first_waypoint - position).angle()
		var second_rotate = direction.angle()
		var last_rotate = (last_waypoint - second_waypoint).angle()
		if abs(second_rotate - first_rotate) > PI:
			if second_rotate < 0:
				second_rotate += PI * 2
			else:
				second_rotate -= PI * 2
		if abs(second_rotate - last_rotate) > PI:
			if last_rotate < 0:
				last_rotate += PI * 2
			else:
				last_rotate -= PI * 2
		anim.track_insert_key(rot_track, lifetime / 3 * 0, rad2deg(first_rotate))
		anim.track_insert_key(rot_track, lifetime / 3 * 2, rad2deg(second_rotate))
		anim.track_insert_key(rot_track, lifetime / 3 * 3, rad2deg(last_rotate))

func update_target_position(position):
	target_position = position
	var direction = (target_position - starting_position).normalized()
	var last_waypoint = target_position - direction * target_radius
	explosion.set_pos(last_waypoint)
	if not player or not anim:
		return
	if not player.is_playing():
		return
	var children = missiles.get_children()
	for i in range(children.size()):
		var track = anim.find_track("%s:transform/pos" % children[i].get_path())
		anim.track_insert_key(track, lifetime, last_waypoint)

func missile_explode():
	missiles.queue_free()
	explosion.connect("finished", self, "on_finished")
	explosion.show()
	explosion.play()

func on_finished():
	queue_free()