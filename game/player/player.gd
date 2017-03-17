extends KinematicBody

export var is_enemy = false
export var forward = Vector3(0, 0, -1)
export var knight_num = 1

export var knight1_speed = 15
export var knight1_fire_interval = 0.2
export var knight1_HP_MAX = 50
export var knight1_turret_cool = 30
export var knight1_regen_cool = 3

export var knight1_bullet_speed = 30
export var knight1_bullet_mass = 1
export var knight1_bullet_scale = 1
export var knight1_bullet_damage = 10
export var knight1_bullet_decay_time= 1.5

export var knight2_speed = 15
export var knight2_fire_interval = 1
export var knight2_HP_MAX = 50
export var knight2_turret_cool = 30
export var knight2_regen_cool = 3

export var knight2_bullet_speed = 10
export var knight2_bullet_mass = 10000
export var knight2_bullet_scale = 10
export var knight2_bullet_damage = 50
export var knight2_bullet_decay_time= 4

export var knight3_speed = 15
export var knight3_fire_interval = 0.5
export var knight3_HP_MAX = 10
export var knight3_turret_cool = 30
export var knight3_regen_cool = 3

export var knight3_bullet_speed = 20
export var knight3_bullet_mass = 1
export var knight3_bullet_scale = 1
export var knight3_bullet_damage = 1
export var knight3_bullet_decay_time= 1.5

var speed = knight1_speed
var fire_interval = knight1_fire_interval
var HP_MAX = knight1_HP_MAX
var turret_cool = knight1_turret_cool
var knight_regen_cool = knight1_regen_cool
var bullet_speed = knight1_bullet_speed
var bullet_mass = knight1_bullet_mass
var bullet_scale = knight1_bullet_scale
var bullet_damage = knight1_bullet_damage
var bullet_decay_time= knight1_bullet_decay_time

var fire_timeout = 0
var regen_timeout = 0
var enemy_moving_left = false
var on_left_edge = false
var on_right_edge = false
var enemy_moving_state = 0
var collision_shape = SphereShape.new()
var hp = 0
var turret_remain = 0
var is_dead = false

func _ready():
	if knight_num == 1:
		speed = knight1_speed
		fire_interval = knight1_fire_interval
		HP_MAX = knight1_HP_MAX
		turret_cool = knight1_turret_cool
		knight_regen_cool = knight1_regen_cool
		bullet_speed = knight1_bullet_speed
		bullet_mass = knight1_bullet_mass
		bullet_scale = knight1_bullet_scale
		bullet_damage = knight1_bullet_damage
		bullet_decay_time= knight1_bullet_decay_time
	elif knight_num == 2:
		speed = knight2_speed
		fire_interval = knight2_fire_interval
		HP_MAX = knight2_HP_MAX
		turret_cool = knight2_turret_cool
		knight_regen_cool = knight2_regen_cool
		bullet_speed = knight2_bullet_speed
		bullet_mass = knight2_bullet_mass
		bullet_scale = knight2_bullet_scale
		bullet_damage = knight2_bullet_damage
		bullet_decay_time= knight2_bullet_decay_time
	elif knight_num == 3:
		speed = knight3_speed
		fire_interval = knight3_fire_interval
		HP_MAX = knight3_HP_MAX
		turret_cool = knight3_turret_cool
		knight_regen_cool = knight3_regen_cool
		bullet_speed = knight3_bullet_speed
		bullet_mass = knight3_bullet_mass
		bullet_scale = knight3_bullet_scale
		bullet_damage = knight3_bullet_damage
		bullet_decay_time= knight3_bullet_decay_time
		
	if is_enemy:
		get_node("HP").set_pos(Vector2(10, 8))
	else:
		get_node("HP").set_pos(Vector2(10, 602))
	hp = HP_MAX
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
		var turret_str = "ready!" if turret_remain <= 0 else str(turret_remain)
		get_node('HP').set_text('Knight : ' + str(hp) + ', Turret :' + turret_str)

func _process(delta):
	
	if is_dead:
		if regen_timeout > 0:
			regen_timeout -= delta
		else:
			is_dead = false
			hp = HP_MAX
			update_ui()
			regen_timeout = 0
			
	if hp <= 0  && regen_timeout ==0:
		is_dead = true
		regen_timeout = knight_regen_cool
		
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
			
		if on_left_edge || (self.get_translation().x < -9):
			enemy_moving_state = -1
			on_left_edge = false
			
		elif on_right_edge || (self.get_translation().x > 9):
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

		turret_remain -= delta
		if Input.is_key_pressed(KEY_3) and turret_remain <= 0:
			call_turret()
		
		update_ui()

func fire(multiple = false):
	if fire_timeout > 0:
		return
	if is_dead:
		return
	fire_timeout = fire_interval
	
	if multiple:
		create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(15)).normalized())
		create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(-15)).normalized())
	create_bullet(forward)

func create_bullet(direction):
	var bullet = preload('../bullet/bullet.tscn').instance()
	bullet.is_enemy = is_enemy
	bullet.damage = bullet_damage
	bullet.decay_time = bullet_decay_time

	var bullet_mesh = bullet.get_node("MeshInstance")
	collision_shape.set_radius(bullet.get_shape(0).get_radius() * bullet_scale)
	bullet.set_shape(0, collision_shape)
	bullet.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
	bullet.set_linear_velocity(direction * bullet_speed) 
	bullet.set_mass(bullet_mass)
	bullet_mesh.set_scale(bullet_mesh.get_scale() * bullet_scale)
	get_node('../').add_child(bullet)

func call_turret():
	turret_remain = turret_cool
	var turret = preload('../turret/turret.tscn').instance()
	var trans = get_global_transform().orthonormalized()
	trans.origin.y = get_node('../PlayerMothership').get_global_transform().orthonormalized().origin.y
	turret.set_global_transform(trans)
	turret.bullet_speed = 20
	get_node('../').add_child(turret)
	
func reached_left_edge():
	on_left_edge = true

func reached_right_edge():
	on_right_edge = true
