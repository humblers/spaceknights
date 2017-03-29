extends KinematicBody

const DEFAULT_LIFE_TIME = 10
const DEFAULT_BULLET_COOL_TIME = 0.2
const FORWARD_TYPE_SPEED = 5

var addon_type = constants.ADDON
var is_enemy = false
var is_destroyed = false

var from_player = 0
var life_elapsed = 0
var bullet_elapsed = 1

var bullet_damage = 1
var bullet_decay_time = 4
var bullet_speed = 20
var bullet_scale = 0.8
var bullet_mass = 1000
var forward = Vector3(0, 0, -1)
var collision_shape = SphereShape.new()
var hp

func set_bullet_speed(speed):
	bullet_speed(speed)

func destroy():
	if not is_destroyed:
		set_fixed_process(false)
		queue_free()
		is_destroyed = true

func _fixed_process(delta):
	life_elapsed += delta
	if life_elapsed > DEFAULT_LIFE_TIME:
		destroy()
		return
	
	if is_enemy:
		var addon_loc = get_node('../Enemy').get_translation()
		self.set_translation(addon_loc + from_player)
	else:
		var addon_loc = get_node('../Player').get_translation()
		self.set_translation(addon_loc + from_player)

	bullet_elapsed += delta
	if is_enemy:
		forward = Vector3(0, 0, 1)
	if bullet_elapsed > DEFAULT_BULLET_COOL_TIME:
		bullet_elapsed = 0
		bullet_scale = 0.8
		bullet_speed = 60
		create_bullet(forward, Vector3(0, 0, 0))

func create_bullet(direction, width = Vector3(0,0,0)):
	var bullet
	bullet = preload('res://bullet/bullet.tscn').instance()
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
	var addon_loc = self.get_translation()
	if is_enemy:
		set_layer_mask(constants.LM_ENEMY)
		set_collision_mask(constants.LM_PLAYER)
		self.set_translation(addon_loc + Vector3(0,0,-4))
		self.set_rotation_deg(Vector3(0,0,0))
	else:
		set_layer_mask(constants.LM_PLAYER)
		set_collision_mask(constants.LM_ENEMY)
		self.set_translation(addon_loc + Vector3(0,0,4))
		self.set_rotation_deg(Vector3(180,0,180))
		
	set_fixed_process(true)


