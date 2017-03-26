extends KinematicBody

const DEFAULT_LIFE_TIME = 10
const DEFAULT_HP = 100
const DEFAULT_BULLET_COOL_TIME = 0.5
const FORWARD_TYPE_SPEED = 5

var drone_type = constants.DRONE
var is_enemy = false

var hp = DEFAULT_HP
var life_elapsed = 0
var is_destroyed = false
var bullet_elapsed = 1

var bullet_damage = 10
var bullet_decay_time = 4
var bullet_speed = 20
var bullet_scale = 0.8
var bullet_mass = 1000
var forward = Vector3(0, 0, -1)
var collision_shape = SphereShape.new()

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

	bullet_elapsed += delta
	if is_enemy:
		forward = Vector3(0, 0, 1)
	if bullet_elapsed > DEFAULT_BULLET_COOL_TIME:
		bullet_elapsed = 0
		bullet_scale = 0.8
		bullet_speed = 40
		create_bullet(forward, Vector3(-0.5, 0, 0))
		create_bullet(forward, Vector3( 0.5, 0, 0))
		
		bullet_scale = 1
		bullet_speed = 20
		create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(90)).normalized())
		create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(-90)).normalized())

	if drone_type == constants.DRONE:
		get_node('HP').set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
		translate(Vector3(0, 0, FORWARD_TYPE_SPEED * delta))

func create_bullet(direction, width = Vector3(0,0,0)):
	var bullet
	bullet = preload('../bullet/bullet.tscn').instance()
	bullet.is_enemy = is_enemy
	bullet.damage = bullet_damage
	bullet.decay_time = bullet_decay_time
	
	var bullet_mesh = bullet.get_node("MeshInstance")
	collision_shape.set_radius(bullet.get_shape(0).get_radius() * bullet_scale)
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
		set_layer_mask(constants.LM_ENEMY)
		set_collision_mask(constants.LM_PLAYER)
		self.set_translation(drone_loc + Vector3(0,0,-4))
		self.set_rotation_deg(Vector3(0,0,0))
	else:
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
