extends KinematicBody

const DEFAULT_LIFE_TIME = 10
const DEFAULT_BULLET_COOL_TIME = 0.2
const FORWARD_TYPE_SPEED = 5

var is_enemy = false

var life_elapsed = 0
var bullet_elapsed = 1

var bullet_damage = 20
var bullet_decay_time = 4
var bullet_speed = 10
var bullet_scale = 0.8
var bullet_mass = 1000
var forward = Vector3(0, 0, -1)
var collision_shape = SphereShape.new()
var hp

func _process(delta):
	life_elapsed += delta
	if life_elapsed > DEFAULT_LIFE_TIME:
		queue_free()
		return

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
	bullet.add_to_group("enemy" if is_enemy else "player")
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
	add_to_group("enemy" if is_enemy else "player")
	var addon_loc = self.get_translation()
	if is_enemy:
		self.set_translation(addon_loc + Vector3(0,0,-4))
		self.set_rotation_deg(Vector3(0,0,0))
	else:
		self.set_translation(addon_loc + Vector3(0,0,4))
		self.set_rotation_deg(Vector3(180,0,180))
		
	set_process(true)


