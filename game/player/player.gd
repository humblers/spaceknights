extends KinematicBody

export var is_ai = false
export var is_enemy = false
export var forward = Vector3(0, 0, -1)
export var knight_num = 0

var knight_skill_queue = []
var random_skill_queue
var speed
var fire_interval
var HP_MAX
var skill_cool
var regen_cool
var bullet_type
var bullet_hp
var bullet_speed
var bullet_mass
var bullet_scale
var bullet_damage
var bullet_decay_time
var bullet_is_cannon
var bullet_is_mass

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
var skill_num = 0
var life = 3

func _ready():
	var player = "player1" if not is_enemy else "player2"
	random_skill_queue = [] + start.get("%s_skill_queue" % player)
	knight_num = start.get("%s_type" % player)
	
	while random_skill_queue.size() > 0:		
		var random_num = randi() % random_skill_queue.size()
		knight_skill_queue.append(random_skill_queue[random_num])
		random_skill_queue.remove(random_num)		
	
	for i in range(knight_skill_queue.size()):
		print('ran skill num = ', i, ' contents ' , knight_skill_queue[i])
	
	skill_num = knight_skill_queue.size()
	
	
	var knight_infos = constants.KNIGHTS
	if knight_num < 0 or knight_num >= knight_infos.size():
		knight_num = randi() % knight_infos.size()
	var knight_info = knight_infos[knight_num]
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
		get_node("Life").set_pos(Vector2(10, 23))
		set_layer_mask(constants.LM_ENEMY)
		set_collision_mask(constants.LM_PLAYER)
		start.red_life = life
	else:
		get_node("HP").set_pos(Vector2(10, 602))
		get_node("Life").set_pos(Vector2(10, 587))
		set_layer_mask(constants.LM_PLAYER)
		set_collision_mask(constants.LM_ENEMY)
		start.blue_life = life

	hp = HP_MAX
	update_ui()
	add_to_group("unfreed_nodes")

	set_process(true)

func _on_Area_body_enter( body ):
	if (!is_enemy && body.is_in_group("enemy_Bullet")) || (is_enemy && body.is_in_group("player_Bullet")):
		hp = clamp(hp - body.damage, 0, HP_MAX)
		update_ui()
		body.queue_free()	
	if (!is_enemy && body.is_in_group("enemy_Cannon")) || (is_enemy && body.is_in_group("player_Cannon")):
		hp = clamp(hp - body.damage, 0, HP_MAX)
		update_ui()

func update_ui():
	if is_enemy:
		get_node('HP').set_text('Knight : ' + str(hp))
		get_node('Life').set_text('Life : ' + str(life))
	else:
		var skill_str = "??"
		if skill_num == 0:
			pass
		elif skill_num-2 < 0:
			if skill_remain <= 0:
				skill_str = "<" +constants.SKILLS[knight_skill_queue[skill_num-1]-1]["name"] + "> is ready!"
			else:
				skill_str = "Next Magazine"+ "%d" % skill_remain + "s"
		else:
			if skill_remain <= 0:
				skill_str = "<" +constants.SKILLS[knight_skill_queue[skill_num-1]-1]["name"] + "> is ready!"
			else:
				skill_str = "<" + constants.SKILLS[knight_skill_queue[skill_num-1]-1]["name"] + "> is " + "%d" % skill_remain + "s remain"
			
		if knight_skill_queue.size() <= 0:
			skill_str = "empty!"
		get_node('HP').set_text('Knight : ' + str(hp) + ',     ' + skill_str)
		get_node('Life').set_text('Life : ' + str(life))

func _process(delta):	
	if is_dead:
		if regen_timeout > 0:
			regen_timeout -= delta
		else:
			is_dead = false
			hp = HP_MAX
			update_ui()
			regen_timeout = 0
			self.show()
			if is_enemy:
				set_layer_mask(constants.LM_ENEMY)
				set_collision_mask(constants.LM_PLAYER)
			else:
				set_layer_mask(constants.LM_PLAYER)
				set_collision_mask(constants.LM_ENEMY)
	
	skill_remain -= delta
	
	if hp <= 0  && regen_timeout == 0:
		is_dead = true
		regen_timeout = regen_cool
		self.hide()
		life -= 1
		update_ui()
		if is_enemy:
			start.red_life -= 1
			set_layer_mask(constants.LM_DONT_COLLIDE)
			set_collision_mask(constants.LM_DONT_COLLIDE)
		else:
			start.blue_life -= 1
			set_layer_mask(constants.LM_DONT_COLLIDE)
			set_collision_mask(constants.LM_DONT_COLLIDE)
		if life <=0 and not start.gameover:
			if is_enemy:
				start.blue_score += 1
				start.red_life = 0
			else:
				start.red_score += 1
				start.blue_life = 0
			start.gameover = true
			var popup = preload('res://ui/score_popup.tscn').instance()
			get_node('../').add_child(popup)
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
			self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,-30))
		elif enemy_moving_state == -1:
			self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,30))
		else:
			self.get_node("MeshInstance").set_rotation_deg(Vector3(0,0,0))
		activate_skill()
		fire()
	else:
		fire()
		
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

		if Input.is_key_pressed(KEY_SPACE):
			activate_skill()
	update_ui()
	if bullet_type == 4:
		if !is_hold_fire:
			if laser:
				if is_enemy:
					get_tree().get_nodes_in_group("enemy_Laser")[0].queue_free()
					laser = null
				else:
					get_tree().get_nodes_in_group("player_Laser")[0].queue_free()
					laser = null
		else:
			if weakref(laser).get_ref():
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
		bullet = preload('../bullet/rocket.tscn').instance()
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
	#if is_enemy:
		#bullet_mesh.set_rotation_deg(Vector3(180,0,0))
	get_node('../').add_child(bullet)

func create_laser(direction):
	if !laser:
		laser = preload('../bullet/laser.tscn').instance()
		laser.is_enemy = is_enemy
		
		laser.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
		get_node('../').add_child(laser)

func activate_skill():
	if is_ai && get_node('../').has_node('BlackHole'):
		return
	
	
	if knight_skill_queue.size() <= 0:
		return
	if skill_num <= 0:
		skill_num = knight_skill_queue.size()
		
	if skill_remain > 0:
		return
	
	skill_num -= 1
	var skill = knight_skill_queue[skill_num]
	print('cool ' , constants.SKILLS[skill-1]["cool"])
	
	skill_remain = constants.SKILLS[skill-1]["cool"]
	if skill == constants.TURRET:
		call_turret(skill)
	elif skill == constants.DRONE:
		call_drone(skill)
	elif skill == constants.BLACKHOLE:
		summon_blackhole()
	elif skill == constants.ADDON:
		call_addon(skill)
	elif skill == constants.CHARGE:
		call_charge(skill)
		
func summon_blackhole():
	var blackhole = preload('../skills/blackhole/blackhole.tscn').instance()
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
	var turret = preload('../skills/turret/turret.tscn').instance()
	turret.turret_type = type
	turret.is_enemy = is_enemy
	var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
	var trans = get_global_transform().orthonormalized()
	trans.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
	turret.set_global_transform(trans)
	get_node('../').add_child(turret)

func call_drone(type):
	var drone = preload('../skills/drone/drone.tscn').instance()
	drone.drone_type = type
	drone.is_enemy = is_enemy
	var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
	var trans = get_global_transform().orthonormalized()
	trans.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
	drone.set_global_transform(trans)
	get_node('../').add_child(drone)
	
func call_addon(type):
	var addon1 = preload('../skills/addon/addon.tscn').instance()
	addon1.addon_type = type
	addon1.is_enemy = is_enemy
	addon1.from_player = Vector3(-1.5, 0, 0)
	var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
	var trans = get_global_transform().orthonormalized()
	trans.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
	addon1.set_global_transform(trans)
	get_node('../').add_child(addon1)
	
	var addon2 = preload('../skills/addon/addon.tscn').instance()
	addon2.addon_type = type
	addon2.is_enemy = is_enemy
	addon2.from_player = Vector3(1.5, 0, 0)
	var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
	var trans = get_global_transform().orthonormalized()
	trans.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
	addon2.set_global_transform(trans)
	get_node('../').add_child(addon2)
	
func call_charge(type):
	var charge = preload('../skills/charge/charge.tscn').instance()
	charge.charge_type = type
	charge.is_enemy = is_enemy
	var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
	var trans = get_global_transform().orthonormalized()
	trans.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
	charge.set_global_transform(trans)
	get_node('../').add_child(charge)
	
	var charge1 = preload('../skills/charge/charge.tscn').instance()
	charge1.charge_type = type
	charge1.is_enemy = is_enemy
	var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
	var trans1 = get_global_transform().orthonormalized()
	trans1.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
	trans1.origin.x -= 3
	trans1.origin.z -= 4
	charge1.set_global_transform(trans1)
	get_node('../').add_child(charge1)
	
	var charge2 = preload('../skills/charge/charge.tscn').instance()
	charge2.charge_type = type
	charge2.is_enemy = is_enemy
	var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
	var trans2 = get_global_transform().orthonormalized()
	trans2.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
	trans2.origin.x += 3
	trans2.origin.z += 4
	charge2.set_global_transform(trans2)
	get_node('../').add_child(charge2)

func reached_left_edge():
	on_left_edge = true

func reached_right_edge():
	on_right_edge = true
