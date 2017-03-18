extends StaticBody

const DEFAULT_LIFE_TIME = 10
const DEFAULT_BULLET_COOL_TIME = 0.5

var is_enemy = false

var life_elapsed = 0
var bullet_elapsed = 1

var bullet_speed = 0
var bullet_vector = Vector3(0, 0, -1)

func set_bullet_speed(speed):
	bullet_speed(speed)
	
func _fixed_process(delta):
	bullet_elapsed += delta
	life_elapsed += delta
	if is_enemy:
		bullet_vector = Vector3(0, 0, 1)
	if bullet_elapsed > DEFAULT_BULLET_COOL_TIME:
		bullet_elapsed = 0
		var bullet = preload('../bullet/bullet.tscn').instance()
		bullet.is_enemy = false
		var bullet_mesh = bullet.get_node("MeshInstance")
		bullet.set_global_transform(get_node("ShotFrom").get_global_transform().orthonormalized())
		bullet.set_linear_velocity(bullet_vector * bullet_speed) 
		get_node('../../').add_child(bullet)

	if life_elapsed > DEFAULT_LIFE_TIME:
		set_fixed_process(false)
		get_parent().remove_child(self)
		queue_free()

func _ready():
	set_fixed_process(true)