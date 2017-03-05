extends KinematicBody

const speed = 5

func _ready():
	set_process(true)
	
func _process(delta):
	if Input.is_key_pressed(KEY_LEFT):
		self.translate(Vector3(-speed * delta, 0, 0))
	elif Input.is_key_pressed(KEY_RIGHT):
		self.translate(Vector3(speed * delta, 0, 0))