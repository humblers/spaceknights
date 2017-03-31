extends KinematicBody

const DEFAULT_LIFE_TIME = 100
const DEFAULT_HP = 400
const DEFAULT_BULLET_COOL_TIME = 0.4
const DEFAULT_ATTACK_COOL_TIME = 4
const DEFAULT_ATTACK_CHAIN = 1
const FORWARD_TYPE_SPEED = 5

var drone_type = constants.DRONE
var is_enemy = false

var hp = DEFAULT_HP
var life_elapsed = 0
var is_destroyed = false
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
var collider_damage = 100

onready var hp_label = Label.new()

func set_bullet_speed(speed):
	bullet_speed(speed)
	
func update_ui():
	hp_label.set_text('HP : %d' % hp)

func destroy():
	if not is_destroyed:
		set_fixed_process(false)
		queue_free()
		is_destroyed = true

func _fixed_process(delta):
	life_elapsed += delta
	if life_elapsed > DEFAULT_LIFE_TIME or hp <= 0:
		destroy()
		return

	attack_timing += delta
	bullet_elapsed += delta
	rotate_timing += delta
	if rotate_timing > 360:
		rotate_timing = 0
	if is_enemy:
		forward = Vector3(0, 0, 1)
	if attack_timing > DEFAULT_ATTACK_COOL_TIME:
		if attack_chain >= 0:
			if bullet_elapsed > DEFAULT_BULLET_COOL_TIME:
				bullet_elapsed = 0
				bullet_speed = 7
				#create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(100*attack_timing-420)).normalized())
				#print(100*attack_timing-420)
				for i in range(0, 12):
					create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(i*30)).normalized())

				attack_chain -= 1
		else:
			attack_chain = DEFAULT_ATTACK_CHAIN
			attack_timing = 0

	if drone_type == constants.DRONE:
		get_node('HP').set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
		translate(Vector3(0, 0, FORWARD_TYPE_SPEED * delta))
		self.get_node("MeshInstance").set_rotation_deg(Vector3(0,100*rotate_timing,0))
		self.get_node("ShotFrom").set_rotation_deg(Vector3(0,100*rotate_timing,0))

func create_bullet(direction, width = Vector3(0,0,0)):
	var bullet
	bullet = preload('res://bullet/bullet.tscn').instance()
	bullet.is_enemy = is_enemy
	bullet.damage = bullet_damage
	bullet.decay_time = bullet_decay_time
	bullet_scale = 0.5
	if is_enemy:
		bullet.is_critical = true
		bullet_scale = 1.5
	
	var bullet_mesh = bullet.get_node("MeshInstance")
	#collision_shape.set_radius(bullet.get_shape(0).get_radius() * bullet_scale)
	bullet.set_shape(0, collision_shape)
	bullet.set_global_transform(get_node("ShotFrom").get_global_transform().orthonormalized())
	bullet.translate(width)
	bullet.set_linear_velocity(direction * bullet_speed) 
	bullet.set_mass(bullet_mass)
	bullet_mesh.set_scale(bullet_mesh.get_scale() * bullet_scale)
	if is_enemy:
		bullet_mesh.set_rotation_deg(Vector3(180,0,0))
	get_node('../').add_child(bullet)


func _ready():
	var drone_loc = self.get_translation()
	if is_enemy:
		add_to_group('enemy_Collider')
		set_layer_mask(constants.LM_ENEMY)
		set_collision_mask(constants.LM_PLAYER)
		self.set_translation(drone_loc + Vector3(0,0,-4))
		self.set_rotation_deg(Vector3(0,0,0))
	else:
		add_to_group('player_Collider')
		set_layer_mask(constants.LM_PLAYER)
		set_collision_mask(constants.LM_ENEMY)
		self.set_translation(drone_loc + Vector3(0,0,4))
		self.set_rotation_deg(Vector3(180,0,180))
	self.set_scale(Vector3(0.5,0.5,0.5))	
	
	hp_label.set_name('HP')
	hp_label.set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
	add_child(hp_label)
	hp_label.set_text('HP : %d' % hp)
	set_fixed_process(true)


func _on_DroneArea_body_enter( body ):
	if (!is_enemy && body.is_in_group("enemy_Bullet")) || (is_enemy && body.is_in_group("player_Bullet")):
		body.queue_free()
		hp = clamp(hp - body.damage, 0, DEFAULT_HP)
		update_ui()
	if (!is_enemy && body.is_in_group("enemy_Cannon")) || (is_enemy && body.is_in_group("player_Cannon")):
		hp = clamp(hp - body.damage, 0, DEFAULT_HP)
		update_ui()
