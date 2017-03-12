extends KinematicBody

export var speed = 15
export var bullet_speed = 20

var fired = false
var prev_fired = false
var forward = Vector3(0, 0, -1)

func _ready():
	add_to_group("unfreed_nodes")
	if get_rotation().y > 0:
		forward = Vector(0, 0, 1)
	set_process(true)

func _process(delta):
	if Input.is_key_pressed(KEY_LEFT):
		translate(Vector3(-speed * delta, 0, 0))
	elif Input.is_key_pressed(KEY_RIGHT):
		translate(Vector3(speed * delta, 0, 0))
	
	var fired = Input.is_key_pressed(KEY_SPACE)
	if fired and not prev_fired:
		var bullet = preload('../bullet/bullet.tscn').instance()
		bullet.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
		bullet.set_linear_velocity(forward * bullet_speed) 
		get_node('../').add_child(bullet)
	prev_fired = fired

func _on_Area_body_exit( body ):
	pass