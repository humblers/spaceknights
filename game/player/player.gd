extends KinematicBody

export var is_enemy = false
export var forward = Vector3(0, 0, -1)
export var knight_num = 0

var knight_total_num = 4
# default shooter
var knight1_speed = 15
var knight1_fire_interval = 0.2
var knight1_HP_MAX = 50
var knight1_turret_cool = 3
var knight1_regen_cool = 3

var knight1_bullet_type = 1
var knight1_bullet_hp = 20
var knight1_bullet_speed = 30
var knight1_bullet_mass = 10
var knight1_bullet_scale = 1
var knight1_bullet_damage = 15
var knight1_bullet_decay_time= 1.5
var knight1_bullet_is_heavy_mass = false

# big shooter
var knight2_speed = 15
var knight2_fire_interval = 1
var knight2_HP_MAX = 50
var knight2_turret_cool = 3
var knight2_regen_cool = 3

var knight2_bullet_type = 1
var knight2_bullet_hp = 80
var knight2_bullet_speed = 10
var knight2_bullet_mass = 100000
var knight2_bullet_scale = 10
var knight2_bullet_damage = 50
var knight2_bullet_decay_time= 4
var knight2_bullet_is_heavy_mass = true

# 3way shooter
var knight3_speed = 15
var knight3_fire_interval = 0.2
var knight3_HP_MAX = 50
var knight3_turret_cool = 3
var knight3_regen_cool = 3

var knight3_bullet_type = 2
var knight3_bullet_hp = 20
var knight3_bullet_speed = 30
var knight3_bullet_mass = 1
var knight3_bullet_scale = 1
var knight3_bullet_damage = 5
var knight3_bullet_decay_time= 1.5
var knight3_bullet_is_heavy_mass = false

# heavy shooter
var knight4_speed = 30
var knight4_fire_interval = 0.1
var knight4_HP_MAX = 50
var knight4_turret_cool = 3
var knight4_regen_cool = 3

var knight4_bullet_type = 3
var knight4_bullet_hp = 10
var knight4_bullet_speed = 50
var knight4_bullet_mass = 1
var knight4_bullet_scale = 0.8
var knight4_bullet_damage = 2
var knight4_bullet_decay_time= 1.5
var knight4_bullet_is_heavy_mass = false

var speed = knight1_speed
var fire_interval = knight1_fire_interval
var HP_MAX = knight1_HP_MAX
var turret_cool = knight1_turret_cool
var regen_cool = knight1_regen_cool
var bullet_type = knight1_bullet_type
var bullet_hp = knight1_bullet_hp
var bullet_speed = knight1_bullet_speed
var bullet_mass = knight1_bullet_mass
var bullet_scale = knight1_bullet_scale
var bullet_damage = knight1_bullet_damage
var bullet_decay_time= knight1_bullet_decay_time
var bullet_is_heavy_mass = knight1_bullet_is_heavy_mass

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
	if knight_num == 0:
		knight_num = randi() % knight_total_num + 1
	if knight_num == 1:
		speed = knight1_speed
		fire_interval = knight1_fire_interval
		HP_MAX = knight1_HP_MAX
		turret_cool = knight1_turret_cool
		regen_cool = knight1_regen_cool
		bullet_type = knight1_bullet_type
		bullet_hp = knight1_bullet_hp
		bullet_speed = knight1_bullet_speed
		bullet_mass = knight1_bullet_mass
		bullet_scale = knight1_bullet_scale
		bullet_damage = knight1_bullet_damage
		bullet_decay_time= knight1_bullet_decay_time
		bullet_is_heavy_mass = knight1_bullet_is_heavy_mass
	elif knight_num == 2:
		speed = knight2_speed
		fire_interval = knight2_fire_interval
		HP_MAX = knight2_HP_MAX
		turret_cool = knight2_turret_cool
		regen_cool = knight2_regen_cool
		bullet_type = knight2_bullet_type
		bullet_hp = knight2_bullet_hp
		bullet_speed = knight2_bullet_speed
		bullet_mass = knight2_bullet_mass
		bullet_scale = knight2_bullet_scale
		bullet_damage = knight2_bullet_damage
		bullet_decay_time= knight2_bullet_decay_time
		bullet_is_heavy_mass = knight2_bullet_is_heavy_mass
	elif knight_num == 3:
		speed = knight3_speed
		fire_interval = knight3_fire_interval
		HP_MAX = knight3_HP_MAX
		turret_cool = knight3_turret_cool
		regen_cool = knight3_regen_cool
		bullet_type = knight3_bullet_type
		bullet_hp = knight3_bullet_hp
		bullet_speed = knight3_bullet_speed
		bullet_mass = knight3_bullet_mass
		bullet_scale = knight3_bullet_scale
		bullet_damage = knight3_bullet_damage
		bullet_decay_time= knight3_bullet_decay_time
		bullet_is_heavy_mass = knight3_bullet_is_heavy_mass
	elif knight_num == 4:
		speed = knight4_speed
		fire_interval = knight4_fire_interval
		HP_MAX = knight4_HP_MAX
		turret_cool = knight4_turret_cool
		regen_cool = knight4_regen_cool
		bullet_type = knight4_bullet_type
		bullet_hp = knight4_bullet_hp
		bullet_speed = knight4_bullet_speed
		bullet_mass = knight4_bullet_mass
		bullet_scale = knight4_bullet_scale
		bullet_damage = knight4_bullet_damage
		bullet_decay_time= knight4_bullet_decay_time
		bullet_is_heavy_mass = knight4_bullet_is_heavy_mass
		
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
		var turret_str = "ready!" if turret_remain <= 0 else "%.0f" % turret_remain
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
	
	turret_remain -= delta
	
	if hp <= 0  && regen_timeout ==0:
		is_dead = true
		regen_timeout = regen_cool
		
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
			
		if on_left_edge || (self.get_translation().x < -10):
			enemy_moving_state = -1
			on_left_edge = false
			
		elif on_right_edge || (self.get_translation().x > 10):
			enemy_moving_state = 1
			on_right_edge = false
			
		translate(Vector3(speed * delta * enemy_moving_state, 0, 0))
		if enemy_moving_state == 1:
			self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,50))
		elif enemy_moving_state == -1:
			self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,-50))
		else:
			self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,0))
		#call_turret(constants.TURRET_FIXED_TYPE)
		fire()
	else:
		if Input.is_key_pressed(KEY_LEFT) and not on_left_edge:
			on_right_edge = false
			self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,30))
			translate(Vector3(-speed * delta, 0, 0))
		elif Input.is_key_pressed(KEY_RIGHT) and not on_right_edge:
			on_left_edge = false
			translate(Vector3(speed * delta, 0, 0))
			self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,-30))
		else :
			self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,0))

		if Input.is_key_pressed(KEY_1):
			pass
		#	fire()
		elif Input.is_key_pressed(KEY_2):
			pass
		#	fire(true)

		if Input.is_key_pressed(KEY_1):
			call_turret(constants.TURRET_FIXED_TYPE)
		if Input.is_key_pressed(KEY_2):
			call_turret(constants.TURRET_FORWARD_TYPE)
		if Input.is_key_pressed(KEY_SPACE):
			fire()
		
		update_ui()

func fire():
	
	if fire_timeout > 0:
		return
	if is_dead:
		return
	fire_timeout = fire_interval
	
	if bullet_type == 1:
		create_bullet(forward)
	elif bullet_type == 2:
		create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(15)).normalized())
		create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(-15)).normalized())
		create_bullet(forward)
	elif bullet_type == 3:
		create_bullet(forward, Vector3(-2, 0, 0))
		create_bullet(forward, Vector3( 2, 0, 0))
		create_bullet(forward, Vector3(-1, 0, 0))
		create_bullet(forward, Vector3( 1, 0, 0))
		create_bullet(forward)
	

func create_bullet(direction, width = Vector3(0,0,0)):
	var bullet = preload('../bullet/bullet.tscn').instance()
	bullet.is_enemy = is_enemy
	bullet.hp = bullet_hp
	bullet.HP_MAX = bullet_hp
	bullet.damage = bullet_damage
	bullet.decay_time = bullet_decay_time
	bullet.is_heavy_mass = bullet_is_heavy_mass

	var bullet_mesh = bullet.get_node("MeshInstance")
	collision_shape.set_radius(bullet.get_shape(0).get_radius() * bullet_scale)
	bullet.set_shape(0, collision_shape)
	bullet.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
	bullet.translate(width)
	bullet.set_linear_velocity(direction * bullet_speed) 
	bullet.set_mass(bullet_mass)
	bullet_mesh.set_scale(bullet_mesh.get_scale() * bullet_scale)
	get_node('../').add_child(bullet)

func call_turret(turret_type):
	if turret_remain > 0:
		return
	turret_remain = turret_cool
	var turret = preload('../turret/turret.tscn').instance()
	var trans = get_global_transform().orthonormalized()
	var mothership_node
	if is_enemy:
		mothership_node = get_node('../EnemyMothership')
	else:
		mothership_node = get_node('../PlayerMothership')
	trans.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
	turret.set_global_transform(trans)
	turret.bullet_speed = 20
	turret.is_enemy = is_enemy
	turret.turret_type = turret_type
	get_node('../').add_child(turret)

func reached_left_edge():
	on_left_edge = true

func reached_right_edge():
	on_right_edge = true
