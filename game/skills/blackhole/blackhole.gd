extends RigidBody

var is_enemy = true
var initial_scale
var time = 0
var creating_time = 15
var blackhole_scale = 0
var MAX_SCALE = 0.4
var hp

func _ready():
	var bullet_from = get_node("../%s/BulletFrom" % ("Enemy" if is_enemy else "Player"))
	set_global_transform(bullet_from.get_global_transform().orthonormalized())
	var xyz = Vector3(0,0,0)
	xyz.x = get_translation().x
	if is_enemy:
		xyz.z = 3
	else:
		xyz.z = -3
	set_translation(xyz)

	add_to_group("enemy" if is_enemy else "player")
	get_node("Range").add_to_group("enemy" if is_enemy else "player")

	set_process(true)
	
func _process(delta):
	time += delta*1
	blackhole_scale = clamp(time/creating_time, 0.1, MAX_SCALE)
	get_node("MeshInstance").set_scale(Vector3(blackhole_scale , blackhole_scale, blackhole_scale))
	if blackhole_scale == MAX_SCALE:
		queue_free()
