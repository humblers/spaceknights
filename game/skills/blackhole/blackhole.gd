extends RigidBody

var is_enemy = true
var initial_scale
var time = 0
var creating_time = 15
var blackhole_scale = 0
var MAX_SCALE = 0.6

func _on_BlackHole_body_enter( body ):
	if (body.is_in_group("enemy_Bullet") and not is_enemy) \
	or (body.is_in_group("player_Bullet") and is_enemy):
		body.queue_free()
		
	if (body.is_in_group("enemy_Cannon") and not is_enemy) \
	or (body.is_in_group("player_Cannon") and is_enemy):
		body.queue_free()
		
func _ready():
	if is_enemy:
		set_layer_mask(constants.LM_ENEMY)
		set_collision_mask(constants.LM_PLAYER)
		get_node("Range").set_layer_mask(constants.LM_ENEMY)
		get_node("Range").set_collision_mask(constants.LM_PLAYER)
	else:
		set_layer_mask(constants.LM_PLAYER)
		set_collision_mask(constants.LM_ENEMY)
		get_node("Range").set_layer_mask(constants.LM_PLAYER)
		get_node("Range").set_collision_mask(constants.LM_ENEMY)

	set_process(true)
	
func _process(delta):
	time += delta*2
	blackhole_scale = clamp(time/creating_time, 0.1, MAX_SCALE)
	get_node("MeshInstance").set_scale(Vector3(blackhole_scale , blackhole_scale, blackhole_scale))
	if blackhole_scale == MAX_SCALE:
		queue_free()
