extends KinematicBody

export var is_enemy = false
export var speed = 15
export var bullet_speed = 20
export var forward = Vector3(0, 0, -1)
export var bullet_mass = 1
export var bullet_scale = 1
export var fire_interval = 0.5
export var HP_MAX = 1000

var fire_timeout = 0
var enemy_moving_left = false
var on_left_edge = false
var on_right_edge = false
var enemy_moving_state = 0
var collision_shape = SphereShape.new()
var hp = HP_MAX

func _ready():
	if is_enemy:
		get_node("HP").set_pos(Vector2(10, 8))
	else:
		get_node("HP").set_pos(Vector2(10, 602))
	update_ui()
	add_to_group("unfreed_nodes")
	set_process(true)

func _on_Area_body_enter( body ):
	if (!is_enemy && body.is_in_group("enemy_Bullet")) || (is_enemy && body.is_in_group("player_Bullet")):
		hp = clamp(hp - body.damage, 0, HP_MAX)
		update_ui()
		body.queue_free()

func update_ui():
	if is_enemy:
		get_node('HP').set_text('Knight : ' + str(hp))
	else:
		get_node('HP').set_text('Knight : ' + str(hp))

func _process(delta):
	#|| self.get_transform()
	print("loc " , self.get_translation())
	
	if fire_timeout > 0:
		fire_timeout -= delta
	
	if is_enemy:
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
			
		if on_left_edge :
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
		if Input.is_key_pressed(KEY_3):
			call_turret()

func fire(multiple = false):
	if fire_timeout > 0:
		return
	fire_timeout = fire_interval	
	
	if multiple:
		create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(30)).normalized())
		create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(-30)).normalized())
	create_bullet(forward)

func create_bullet(direction):
	var bullet = preload('../bullet/bullet.tscn').instance()
	bullet.is_enemy = is_enemy
	var bullet_mesh = bullet.get_node("MeshInstance")
	collision_shape.set_radius(bullet.get_shape(0).get_radius() * bullet_scale)
	bullet.set_shape(0, collision_shape)
	bullet.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
	bullet.set_linear_velocity(direction * bullet_speed) 
	bullet.set_mass(bullet_mass)
	bullet_mesh.set_scale(bullet_mesh.get_scale() * bullet_scale)
	get_node('../').add_child(bullet)

func call_turret():
	var turret = preload('../turret/turret.tscn').instance()
	var trans = get_global_transform().orthonormalized()
	trans.origin.y = get_node('../PlayerMothership').get_global_transform().orthonormalized().origin.y
	turret.set_global_transform(trans)
	get_node('../').add_child(turret)
	
func reached_left_edge():
	on_left_edge = true

func reached_right_edge():
	on_right_edge = true
