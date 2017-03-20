extends KinematicBody

const DEFAULT_LIFE_TIME = 10
const DEFAULT_HP = 100
const DEFAULT_BULLET_COOL_TIME = 0.3

var turret_type = constants.TURRET_FIXED_TYPE
var is_enemy = false

var hp = DEFAULT_HP
var life_elapsed = 0
var is_destroyed = false
var bullet_elapsed = 1

var bullet_damage = 10
var bullet_decay_time = 4
var bullet_speed = 0
var bullet_vector = Vector3(0, 0, -1)

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
		bullet_vector = Vector3(0, 0, 1)
	if bullet_elapsed > DEFAULT_BULLET_COOL_TIME:
		bullet_elapsed = 0
		var bullet = preload('../bullet/bullet.tscn').instance()
		bullet.is_enemy = is_enemy
		bullet.damage = bullet_damage
		bullet.decay_time = bullet_decay_time
		var bullet_mesh = bullet.get_node("MeshInstance")
		bullet.set_global_transform(get_node("ShotFrom").get_global_transform().orthonormalized())
		bullet.set_linear_velocity(bullet_vector * bullet_speed) 
		get_node('../../').add_child(bullet)


func _ready():
	var turret_loc = self.get_translation()
	if is_enemy:
		self.set_translation(turret_loc + Vector3(0,0,-4))
		self.set_rotation_deg(Vector3(0,0,0))
	else:
		self.set_translation(turret_loc + Vector3(0,0,4))
		self.set_rotation_deg(Vector3(180,0,180))
	self.set_scale(Vector3(0.5,0.5,0.5))	
	
	
	hp_label.set_name('HP')
	hp_label.set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
	add_child(hp_label)
	hp_label.set_text('HP : %d' % hp)
	set_fixed_process(true)

func _on_TurretArea_body_enter( body ):
	if (!is_enemy && body.is_in_group("enemy_Bullet")) || (is_enemy && body.is_in_group("player_Bullet")):
		body.queue_free()
		hp = clamp(hp - body.damage, 0, DEFAULT_HP)
		update_ui()
