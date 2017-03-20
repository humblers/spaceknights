extends RigidBody

export var damage = 1
var life_timer = 0
var decay_time = 1
var is_enemy = false

func _ready():
	if is_enemy:
		add_to_group('enemy_Bullet')
	else:
		add_to_group('player_Bullet')
		var material = get_node("MeshInstance").get_mesh().surface_get_material(0)
		
		material.set_parameter(material.PARAM_EMISSION,Color(1,0,0,1))
		
		get_node("MeshInstance").set_material_override(material)
		
	set_process(true)

func _process(delta):
	life_timer += delta
	if life_timer > decay_time:
		on_timeout_complete()
		life_timer = 0

func on_timeout_complete():
	#pass
	queue_free()
