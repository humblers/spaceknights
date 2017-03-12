extends RigidBody

export var damage = 10
var life_timer = 0
var decay_time = 5

func _ready():
	add_to_group('Bullet')
	set_process(true)

func _process(delta):
	life_timer += delta
	if life_timer > decay_time:
		on_timeout_complete()
		life_timer = 0

func on_timeout_complete():
	queue_free()
