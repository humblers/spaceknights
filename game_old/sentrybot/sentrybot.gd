extends StaticBody

var scene_vars = {}

var hp = 0
var search_range = 0
var shot_range = 0
var shot_cool = constants.INT_MAX
var bullet = {}

var shot_elapsed = 0
var collision_shape = SphereShape.new()
var hp_label = Label.new()
var mothership

func get_distance_to(target):
	return get_translation().distance_to(target.get_translation())

func shot_to_nearest_enemy(delta):
	var enemy = mothership
	for body in get_node("Range").get_overlapping_bodies():
		if body.is_in_group("enemy_Bullet") or body.is_in_group("player_Bullet"):
			continue
		if get_distance_to(body) < get_distance_to(enemy):
			enemy = body
	shot_elapsed += delta
	if shot_elapsed > shot_cool:
		shot_elapsed = 0
		create_bullet((enemy.get_translation() - get_translation()).normalized(), Vector3(0, 0, 0))	

func create_bullet(direction, width = Vector3(0,0,0)):
	var node = preload('res://bullet/rocket.tscn').instance()
	node.add_to_group("enemy" if is_in_group("enemy") else "player")
	node.damage = bullet["damage"]
	node.decay_time = shot_range * 10 / bullet["speed"]
	var bullet_scale = bullet["scale"]
	collision_shape.set_radius(node.get_shape(0).get_radius() * bullet_scale)
	node.set_shape(0, collision_shape)
	node.set_global_transform(get_node("ShotFrom").get_global_transform().orthonormalized())
	node.translate(width)
	node.set_linear_velocity(direction * bullet["speed"]) 
	node.set_mass(bullet["mass"])
	var node_mesh = node.get_node("MeshInstance")
	node_mesh.set_scale(node_mesh.get_scale() * bullet_scale)
	get_node('../').add_child(node)

func update_ui():
	hp_label.set_text('HP : %d' % hp)

func _process(delta):
	if hp <= 0:
		queue_free()
		set_process(false)
		return
	shot_to_nearest_enemy(delta)

func _ready():
	for key in scene_vars:
		set(key, scene_vars[key])
	var is_enemy = is_in_group("enemy")
	mothership = get_node("../%sMothership" % ("Player" if is_enemy else "Enemy"))
	var player_node = get_node("../%s" % ("Enemy" if is_enemy else "Player"))
	var trans = player_node.get_global_transform().orthonormalized()
	trans.origin.z = -4 if is_enemy else 4
	set_global_transform(trans)

	hp_label.set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
	hp_label.set_name('HP')
	hp_label.set_text('HP : %d' % hp)
	add_child(hp_label)

	var range_node = get_node("Range")
	range_node.get_node("CollisionShape").get_shape().set_radius(search_range)
	range_node.add_to_group("enemy" if is_enemy else "player")
	
	set_process(true)

func _on_centrybot_area_body_enter( body ):
	var is_oppenent_side = body.is_in_group("player") if is_in_group("enemy") else is_in_group("enemy")
	if not is_oppenent_side:
		return
	
	if body.is_in_group("bullet") || body.is_in_group("collider"):
		hp -= body.damage
		body.queue_free()
		update_ui()
	if body.is_in_group("cannon"):
		hp -= body.damage
		update_ui()