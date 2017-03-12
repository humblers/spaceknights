extends KinematicBody

export var is_enemy = false
export var speed = 15
export var bullet_speed = 20
export var forward = Vector3(0, 0, -1)
export var bullet_mass = 1
const FIRE_INTERVAL = 0.1
var fire_timeout = 0
var enemy_moving_left = false
var on_left_edge = false
var on_right_edge = false
var enemy_moving_state = 0

func _ready():
	add_to_group("unfreed_nodes")
	set_process(true)

func _process(delta):
	if fire_timeout > 0:
		fire_timeout -= delta
	
	if is_enemy:
		"""
		var pos_x = get_translation().x
		if pos_x > 10 or pos_x < -10:
			enemy_moving_left = not enemy_moving_left
		
		if enemy_moving_left:
			translate(Vector3(-speed * delta, 0, 0))
		else:
			translate(Vector3(speed * delta, 0, 0))
		"""
		
		var ai_control = randi() % 50 + 1
		if ai_control <= 2:
			if enemy_moving_state == 0:
				var init_direction = randi() % 2
				if init_direction == 0:
					enemy_moving_state = -1
				else :
					enemy_moving_state = 1
			else :
				enemy_moving_state = enemy_moving_state * -1
				
		if (ai_control > 49) :
			enemy_moving_state = 0
			
		if on_left_edge:
			enemy_moving_state = -1
			on_left_edge = false
			
		elif on_right_edge:
			enemy_moving_state = 1
			on_right_edge = false
			
		translate(Vector3(speed * delta * enemy_moving_state, 0, 0))
		
		fire()
	else:
		if Input.is_key_pressed(KEY_LEFT) and not on_left_edge:
			on_right_edge = false
			translate(Vector3(-speed * delta, 0, 0))
		elif Input.is_key_pressed(KEY_RIGHT) and not on_right_edge:
			on_left_edge = false
			translate(Vector3(speed * delta, 0, 0))

		if Input.is_key_pressed(KEY_1):
			fire()
		elif Input.is_key_pressed(KEY_2):
			fire(true)

func fire(multiple = false):
	if fire_timeout > 0:
		return
	fire_timeout = FIRE_INTERVAL
	
	if multiple:
		create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(30)).normalized())
		create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(-30)).normalized())
	create_bullet(forward)

func create_bullet(direction):
	var bullet = preload('../bullet/bullet.tscn').instance()
	bullet.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
	bullet.set_linear_velocity(direction * bullet_speed) 
	bullet.set_mass(bullet_mass)
	get_node('../').add_child(bullet)
	
func reached_left_edge():
	on_left_edge = true

func reached_right_edge():
	on_right_edge = true
