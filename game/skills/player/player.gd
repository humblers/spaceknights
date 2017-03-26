extends KinematicBody

export var is_ai = false
export var is_enemy = false
export var forward = Vector3(0, 0, -1)
export var knight_num = 0

var knight_skill_queue

var knight_total_num = 6
# default shooter
var knight1_speed = 15
var knight1_fire_interval = 0.2
var knight1_HP_MAX = 300
var knight1_skill_cool = 3
var knight1_regen_cool = 3

var knight1_bullet_type = 1
var knight1_bullet_hp = 20
var knight1_bullet_speed = 30
var knight1_bullet_mass = 1000
var knight1_bullet_scale = 1
var knight1_bullet_damage = 22
var knight1_bullet_decay_time= 1.5
var knight1_bullet_is_cannon = false
var knight1_bullet_is_mass = false

# big shooter
var knight2_speed = 15
var knight2_fire_interval = 1
var knight2_HP_MAX = 300
var knight2_skill_cool = 3
var knight2_regen_cool = 3

var knight2_bullet_type = 1
var knight2_bullet_hp = 100
var knight2_bullet_speed = 10
var knight2_bullet_mass = 100000
var knight2_bullet_scale = 10
var knight2_bullet_damage = 100
var knight2_bullet_decay_time= 5
var knight2_bullet_is_cannon = false
var knight2_bullet_is_mass = true

# 3way shooter
var knight3_speed = 15
var knight3_fire_interval = 0.2
var knight3_HP_MAX = 300
var knight3_skill_cool = 3
var knight3_regen_cool = 3

var knight3_bullet_type = 2
var knight3_bullet_hp = 20
var knight3_bullet_speed = 30
var knight3_bullet_mass = 1000
var knight3_bullet_scale = 1
var knight3_bullet_damage = 7
var knight3_bullet_decay_time= 1.5
var knight3_bullet_is_cannon = false
var knight3_bullet_is_mass = false

# heavy shooter
var knight4_speed = 30
var knight4_fire_interval = 0.1
var knight4_HP_MAX = 300
var knight4_skill_cool = 3
var knight4_regen_cool = 3

var knight4_bullet_type = 3
var knight4_bullet_hp = 10
var knight4_bullet_speed = 50
var knight4_bullet_mass = 1000
var knight4_bullet_scale = 0.8
var knight4_bullet_damage = 2
var knight4_bullet_decay_time= 1.5
var knight4_bullet_is_cannon = false
var knight4_bullet_is_mass = false

# laser shooter
var knight5_speed = 30
var knight5_fire_interval = 0.2
var knight5_HP_MAX = 300
var knight5_skill_cool = 3
var knight5_regen_cool = 3

var knight5_bullet_type = 4
var knight5_bullet_hp = 20
var knight5_bullet_speed = 30
var knight5_bullet_mass = 1000
var knight5_bullet_scale = 1
var knight5_bullet_damage = 15
var knight5_bullet_decay_time= 1.5
var knight5_bullet_is_cannon = false
var knight5_bullet_is_mass = false

# cannon shooter
var knight6_speed = 15
var knight6_fire_interval = 1
var knight6_HP_MAX = 300
var knight6_skill_cool = 3
var knight6_regen_cool = 3

var knight6_bullet_type = 1
var knight6_bullet_hp = 100
var knight6_bullet_speed = 10
var knight6_bullet_mass = 100000
var knight6_bullet_scale = 10
var knight6_bullet_damage = 100
var knight6_bullet_decay_time= 5
var knight6_bullet_is_cannon = true
var knight6_bullet_is_mass = false

var speed = knight1_speed
var fire_interval = knight1_fire_interval
var HP_MAX = knight1_HP_MAX
var skill_cool = knight1_skill_cool
var regen_cool = knight1_regen_cool
var bullet_type = knight1_bullet_type
var bullet_hp = knight1_bullet_hp
var bullet_speed = knight1_bullet_speed
var bullet_mass = knight1_bullet_mass
var bullet_scale = knight1_bullet_scale
var bullet_damage = knight1_bullet_damage
var bullet_decay_time= knight1_bullet_decay_time
var bullet_is_cannon = knight1_bullet_is_cannon
var bullet_is_mass = knight1_bullet_is_mass 

var fire_timeout = 0
var regen_timeout = 0
var enemy_moving_left = false
var on_left_edge = false
var on_right_edge = false
var enemy_moving_state = 0
var collision_shape = SphereShape.new()
var hp = 0
var skill_remain = 0
var is_dead = false
var is_hold_fire = false
var laser

func _ready():
	var player = "player1" if not is_enemy else "player2"
	knight_skill_queue = [] + start.get("%s_skill_queue" % player)
	knight_num = start.get("%s_type" % player)

	if knight_num == -1:
		knight_num = randi() % constants.KNIGHTS.size()

	var knight_info = constants.KNIGHTS[knight_num]
	speed = knight_info["speed"]
	fire_interval = knight_info["fire_interval"]
	HP_MAX = knight_info["HP_MAX"]
	skill_cool = knight_info["skill_cool"]
	regen_cool = knight_info["regen_cool"]
	bullet_type = knight_info["bullet"]["type"]
	bullet_hp = knight_info["bullet"]["hp"]
	bullet_speed = knight_info["bullet"]["speed"]
	bullet_mass = knight_info["bullet"]["mass"]
	bullet_scale = knight_info["bullet"]["scale"]
	bullet_damage = knight_info["bullet"]["damage"]
	bullet_decay_time= knight_info["bullet"]["decay_time"]
	bullet_is_cannon = knight_info["bullet"]["is_cannon"]
	bullet_is_mass = knight_info["bullet"]["is_mass"]

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
		var skill_str = "ready!" if skill_remain <= 0 else "%d" % skill_remain
		if knight_skill_queue.size() <= 0:
			skill_str = "empty!"
		get_node('HP').set_text('Knight : ' + str(hp) + ', skill :' + skill_str)

func _process(delta):
	
	if is_dead:
		if regen_timeout > 0:
			regen_timeout -= delta
		else:
			is_dead = false
			hp = HP_MAX
			update_ui()
			regen_timeout = 0
	
	skill_remain -= delta
	
	if hp <= 0  && regen_timeout ==0:
		is_dead = true
		regen_timeout = regen_cool
		
	if fire_timeout > 0:
		fire_timeout -= delta
	
	if is_ai:
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
			
		if self.get_translation().x < -10 :
			enemy_moving_state = -1 * forward.z
			on_left_edge = false
			
		elif self.get_translation().x > 10:
			enemy_moving_state = 1  * forward.z
			on_right_edge = false
			
		translate(Vector3(speed * delta * enemy_moving_state, 0, 0))
		if enemy_moving_state == 1:
			if self.get_name() == 'Player':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,30,0))
			elif self.get_name() == 'Enemy':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,-30))
		elif enemy_moving_state == -1:
			if self.get_name() == 'Player':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,-30,0))
			elif self.get_name() == 'Enemy':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,30))
		else:
			if self.get_name() == 'Player':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,180,0))
			elif self.get_name() == 'Enemy':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,0))
		activate_skill()
		fire()
	else:
		fire()
		
		if Input.is_key_pressed(KEY_LEFT) and not on_left_edge:
			on_right_edge = false
			if self.get_name() == 'Player':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,-30,0))
			elif self.get_name() == 'Enemy':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,30))
			translate(Vector3(-speed * delta, 0, 0))			
		elif Input.is_key_pressed(KEY_RIGHT) and not on_right_edge:
			on_left_edge = false
			translate(Vector3(speed * delta, 0, 0))
			if self.get_name() == 'Player':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,30,0))
			elif self.get_name() == 'Enemy':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,-30))
		else :
			if self.get_name() == 'Player':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,-180,0))
			elif self.get_name() == 'Enemy':
				self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,0))

		if Input.is_key_pressed(KEY_SPACE):
			activate_skill()
	update_ui()
	if bullet_type == 4:
		if !is_hold_fire:
			if laser:
				get_node('../').get_node("laser").queue_free()
				laser = null
		else:
			if laser:
				laser.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
				

func fire():
	is_hold_fire = true
	if fire_timeout > 0 && bullet_type != 4:
		return
	if is_dead:
		is_hold_fire = false
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
	elif bullet_type ==4:
		create_laser(forward)
	

func create_bullet(direction, width = Vector3(0,0,0)):
	var bullet
	if bullet_is_cannon:
		bullet = preload('../bullet/cannon.tscn').instance()
		bullet.is_cannon = bullet_is_cannon
	else:
		bullet = preload('../bullet/bullet.tscn').instance()
	bullet.is_enemy = is_enemy
	bullet.hp = bullet_hp
	bullet.HP_MAX = bullet_hp
	bullet.damage = bullet_damage
	bullet.decay_time = bullet_decay_time
	bullet.is_mass = bullet_is_mass
	
	var bullet_mesh = bullet.get_node("MeshInstance")
	collision_shape.set_radius(bullet.get_shape(0).get_radius() * bullet_scale)
	bullet.set_shape(0, collision_shape)
	bullet.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
	bullet.translate(width)
	bullet.set_linear_velocity(direction * bullet_speed) 
	bullet.set_mass(bullet_mass)
	bullet_mesh.set_scale(bullet_mesh.get_scale() * bullet_scale)
	if is_enemy:
		bullet_mesh.set_rotation_deg(Vector3(180,0,0))
	get_node('../').add_child(bullet)

func create_laser(direction):
	if !laser:
		laser = preload('../bullet/laser.tscn').instance()
		laser.is_enemy = is_enemy
		
		laser.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
		get_node('../').add_child(laser)

func activate_skill():
	if is_ai && get_node('../').get_node('BlackHole'):
		return
	if knight_skill_queue.size() <= 0:
		return
	if skill_remain > 0:
		return
	skill_remain = skill_cool
	var skill = knight_skill_queue[0]
	knight_skill_queue.pop_front()
	if skill == constants.TURRET:
		call_turret(skill)
	elif skill == constants.DRONE:
		call_drone(skill)
	elif skill == constants.BLACKHOLE:		
		summon_blackhole()

func summon_blackhole():
	var blackhole = preload('../skills/blackhole.tscn').instance()
	blackhole.is_enemy = is_enemy
	blackhole.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
	#blackhole.set_linear_velocity(forward * 10)
	var xyz = Vector3(0,0,0)
	xyz.x = blackhole.get_translation().x
	if is_enemy:
		xyz.z = 3
	else:
		xyz.z = -3
	blackhole.set_translation(xyz)
	get_node('../').add_child(blackhole)

func call_turret(type):
	var turret = preload('../skills/turret.tscn').instance()
	turret.turret_type = type
	turret.is_enemy = is_enemy
	var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
	var trans = get_global_transform().orthonormalized()
	trans.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
	turret.set_global_transform(trans)
	get_node('../').add_child(turret)

func call_drone(type):
	var drone = preload('../skills/drone.tscn').instance()
	drone.drone_type = type
	drone.is_enemy = is_enemy
	var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
	var trans = get_global_transform().orthonormalized()
	trans.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
	drone.set_global_transform(trans)
	get_node('../').add_child(drone)

func reached_left_edge():
	on_left_edge = true

func reached_right_edge():
	on_right_edge = true
