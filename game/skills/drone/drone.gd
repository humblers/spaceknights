extends Spatial

const DEFAULT_HP = 400
const DEFAULT_BULLET_COOL_TIME = 0.4
const DEFAULT_ATTACK_COOL_TIME = 4
const DEFAULT_ATTACK_CHAIN = 1
const FORWARD_TYPE_SPEED = 5
const ANIMATION_DISTANCE = 50
const RIGHT_BOUNDARY = 20

var position setget set_position, get_position
var mothership;
var animation_direction
var landed = false
var is_enemy = false

var hp = DEFAULT_HP
var bullet_elapsed = 0
var attack_timing = 0
var attack_chain = DEFAULT_ATTACK_CHAIN
var rotate_timing = 0

var bullet_damage = 300
var bullet_decay_time = 10
var bullet_speed = 0
var bullet_scale = 0
var bullet_mass = 1000
var forward = Vector3(0, 0, -1)
var collision_shape = SphereShape.new()
var damage = 100

onready var hp_label = Label.new()

func set_position(pos):
	pos.y = min(pos.y, 0)
	set_translation(pos)

func get_position():
	return get_translation()

func set_bullet_speed(speed):
	bullet_speed(speed)
	
func update_ui():
	hp_label.set_text('HP : %d' % hp)

func get_distance_to(target):
	return get_translation().distance_to(target.get_translation())

func goto_nearest_enemy(delta):
	var enemy = mothership
	for body in get_node("Drone/Range").get_overlapping_bodies():
		if body.is_in_group("enemy_Bullet") or body.is_in_group("player_Bullet"):
			continue
		if get_distance_to(body) < get_distance_to(enemy):
			enemy = body
	var movement = (enemy.get_translation() - get_translation()).normalized() * delta * 10
	set_translation(get_translation() + movement)

func _fixed_process(delta):
	if not landed:
		self.position = self.position + animation_direction * delta * 0.4
		if self.position.y == 0:
			landed = true
			get_node("Drone/AnimationPlayer").stop(true)
	else:
		goto_nearest_enemy(delta)

	if hp <= 0:
		queue_free()
		return

	attack_timing += delta
	bullet_elapsed += delta
	rotate_timing += delta
	if rotate_timing > 360:
		rotate_timing = 0

	if attack_timing > DEFAULT_ATTACK_COOL_TIME:
		if attack_chain >= 0:
			if bullet_elapsed > DEFAULT_BULLET_COOL_TIME:
				bullet_elapsed = 0
				bullet_speed = 7
				#create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(100*attack_timing-420)).normalized())
				#print(100*attack_timing-420)
				
				for i in range(0, 7):
					create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(i*30-90)).normalized())
				
				
				attack_chain -= 1
		else:
			attack_chain = DEFAULT_ATTACK_CHAIN
			attack_timing = 0

	#translate(Vector3(0, 0, FORWARD_TYPE_SPEED * delta))
	get_node("HP").set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
	get_node("Drone/MeshInstance").set_rotation_deg(Vector3(0,100*rotate_timing,0))
	get_node("Drone/ShotFrom").set_rotation_deg(Vector3(0,100*rotate_timing,0))

func create_bullet(direction, width = Vector3(0,0,0)):
	var bullet
	bullet = preload('res://bullet/bullet.tscn').instance()
	bullet.add_to_group("enemy" if is_enemy else "player")
	bullet.damage = bullet_damage
	bullet.decay_time = bullet_decay_time
	bullet_scale = 1.0
	if is_enemy:
		bullet.is_critical = true
		bullet_scale = 1.5
	
	var bullet_mesh = bullet.get_node("MeshInstance")
	bullet.set_shape(0, collision_shape)
	bullet.set_global_transform(get_node("Drone/ShotFrom").get_global_transform().orthonormalized())
	bullet.translate(width)
	bullet.set_linear_velocity(direction * bullet_speed) 
	bullet.set_mass(bullet_mass)
	bullet_mesh.set_scale(bullet_mesh.get_scale() * bullet_scale)
	if is_enemy:
		bullet_mesh.set_rotation_deg(Vector3(180,0,0))
	get_node('../../').add_child(bullet)


func _ready():
	is_enemy = is_in_group("enemy")
	mothership = get_node("../%sMothership" % ("Player" if is_enemy else "Enemy"))	
	var drone = get_node("Drone")
	var player = "Enemy" if is_enemy else "Player"
	var player_node = get_node("../%s" % player)
	var pos_x = player_node.get_translation().x
	var depth = sqrt(pow(ANIMATION_DISTANCE, 2) - pow(RIGHT_BOUNDARY - pos_x, 2))
	var start_pos = Vector3(RIGHT_BOUNDARY, -depth, 0)
	animation_direction = Vector3(pos_x, 0, 0) - start_pos
	set_translation(start_pos)

	drone.add_to_group("enemy" if is_enemy else "player")
	drone.add_to_group("drone")

	if is_enemy:
		set_rotation_deg(Vector3(0,0,0))
	else:
		set_rotation_deg(Vector3(180,0,180))
	set_scale(Vector3(0.5,0.5,0.5))	
	
	hp_label.set_name('HP')
	hp_label.set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
	add_child(hp_label)
	hp_label.set_text('HP : %d' % hp)
	set_fixed_process(true)
	
	if is_enemy:
		Vector3(0, 0, 1)


func _on_DroneArea_body_enter( body ):
	if not variants.is_opponent(self, body):
		return
	if body.is_in_group("bullet") or body.is_in_group("mothership") or body.is_in_group("charge") or body.is_in_group("drone"):
		body.queue_free()
		hp = max(hp - body.damage, 0)
		update_ui()