extends RigidBody

export var damage = 10
var life_timer = 0
var decay_time = 0.8
var is_enemy = false

func _ready():
	if is_enemy:
		add_to_group('enemy_Bullet')
	else:
		add_to_group('player_Bullet')
	#add_to_group('Bullet')
	set_process(true)

func _process(delta):
	life_timer += delta
	if life_timer > decay_time:
		on_timeout_complete()
		life_timer = 0

func on_timeout_complete():
	pass
	#queue_free()
