extends KinematicBody

export var is_enemy = false
export var forward = Vector3(0, 0, -1)
export var knight_num = 0

# Input variables
var origin_x
var mouse_x
var screen_x
var is_mouse_pressed = false
var is_mouse_first_pressed = false
var is_screen_touched = false
var is_screen_first_touched = false

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
var fire2_timeout = 0
var regen_timeout = 0
var enemy_moving_left = false
var enemy_moving_state = 0
var collision_shape = SphereShape.new()
var hp = 0
var skill_remain = 0
var is_dead = false
var is_hold_fire = false
var laser
var skill_num = 0
var life = 10
var skill_progress = false
var skill_progress_time = 1
var select_skill_num = 3
var MAX_ENERGY = 10.0
var energy = MAX_ENERGY
var popup_cool = 1
var is_shield = true
var shield_cool = 0.5

onready var position = get_translation()
var direction = 0

var timer = Timer.new()
const INPUT_SAMPLE_RATE = 30 # times per second
func set_trans_and_direction(t_x, d):
	set_translation(Vector3(t_x, get_translation().y, get_translation().z))
	direction = -d

func _sample():
	if is_enemy:
		return
	
	var packet = {}
	packet["dir"] = direction
	packet["trans_x"] = get_translation().x
	packet["hp"] = hp
	packet["m_hp"] = get_node("../PlayerMothership").hp
	kcp.write(kcp.MOVE_KNIGHT, packet)

func _input(ev):
	if is_enemy:
		return

	if ev.type == InputEvent.SCREEN_TOUCH:
		if ev.pressed:
			is_screen_touched = true
			is_screen_first_touched = true
			origin_x = get_translation().x
		else:
			is_screen_touched = false
		
	if ev.type == InputEvent.SCREEN_DRAG:
		if is_screen_touched:
			if is_screen_first_touched:
				is_screen_first_touched = false
				screen_x = ev.pos.x
			if (ev.pos.x - screen_x) < 0:
				direction = -1
			elif (ev.pos.x - screen_x) > 0:
				direction = 1
			set_translation(Vector3(origin_x  + (ev.pos.x - screen_x) / 13.3, 0, 18))
			
	if ev.type == InputEvent.MOUSE_BUTTON:
		#get_node("../ingame_ui/Error_status").set_text("Click +" + String(ev.pressed))
		#get_node("../ingame_ui").popup_cool = 0.5	
		#get_node("../ingame_ui/Error_status").show()
		
		if ev.pressed:
			is_mouse_pressed = true
			is_mouse_first_pressed = true
			origin_x = get_translation().x
		else:
			is_mouse_pressed = false
			
	if ev.type == InputEvent.MOUSE_MOTION:
		if is_mouse_pressed:
			if is_mouse_first_pressed:
				is_mouse_first_pressed = false
				mouse_x = ev.pos.x
			position = Vector3(origin_x  + (ev.pos.x - mouse_x) / 13.3, 0, 18)
			
func _packet_received(dict):
	dict = dict["message"]
	if is_enemy:
		hp = dict.hp
		update_ui()
		get_node("../EnemyMothership").hp = dict.m_hp
		get_node("../EnemyMothership").update_ui()
		set_trans_and_direction(dict.trans_x, dict.dir)

func _ready():
	set_process_input(true)
	kcp.connect("packet_received", self, "_packet_received")
	timer.connect("timeout", self, "_sample")
	timer.set_wait_time(1.0/INPUT_SAMPLE_RATE)
	add_child(timer)
	timer.start()
	var player = variants.player1_knight if not is_enemy else variants.player2_knight
	random_skill_queue = [] + player["skills"]
	knight_num = player["type"]
	if random_skill_queue.size() < 5:
		random_skill_queue = [ 0, 1, 2, 3, 4 ]

	while random_skill_queue.size() > 0:
		var random_num = randi() % random_skill_queue.size()
		knight_skill_queue.append(random_skill_queue[random_num])
		random_skill_queue.remove(random_num)		

	skill_num = knight_skill_queue.size()

	
	var knight_infos = constants.KNIGHTS
	if knight_num < 0 or knight_num >= knight_infos.size():
		knight_num = randi() % knight_infos.size()
	print("knight num" , knight_num)
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

	add_to_group("enemy" if is_enemy else "player")
	add_to_group("knight")
	if is_enemy:
		variants.red_life = life
		get_node("../ingame_ui").update_ui(knight_skill_queue, is_enemy)
	else:
		variants.blue_life = life
		get_node("../ingame_ui").update_ui(knight_skill_queue, is_enemy)

	hp = HP_MAX
	update_ui()

	set_process(true)

func _on_Area_body_enter( body ):
	if not variants.is_opponent(self, body):
		return
	if body.is_in_group("bullet") or body.is_in_group("charge") or body.is_in_group("drone"):
		take_damage(body.damage if not is_shield else body.damage * 0.1)

func take_damage(damage):
	if is_enemy:
		return
	hp = max(hp - damage, 0)
	update_ui()
	
func update_ui():
	if is_enemy:
		get_node("../ingame_ui/Knight_life2/value").set_text(str(life))
		get_node("../ingame_ui/Knight_hp2/value").set_text(str(round(hp)))
	else:
		get_node("../ingame_ui/Knight_life1/value").set_text(str(life))
		get_node("../ingame_ui/Knight_hp1/value").set_text(str(round(hp)))

func _process(delta):
	if not is_enemy:
		var diff = (get_translation() - position).x
		if  diff != 0:
			set_translation(position)
			if diff < 0:
				direction = 1
			else:
				direction = -1
		else:
			direction = 0
	
		
	if is_dead:
		if regen_timeout > 0:
			regen_timeout -= delta
		else:
			is_dead = false
			hp = HP_MAX
			update_ui()
			regen_timeout = 0
			self.show()
	
	skill_remain -= delta
	
	if hp <= 0  && regen_timeout == 0:
		is_dead = true
		regen_timeout = regen_cool
		self.hide()
		life -= 1
		update_ui()
		if is_enemy:
			variants.red_life -= 1
			set_layer_mask(constants.LM_DONT_COLLIDE)
			set_collision_mask(constants.LM_DONT_COLLIDE)
		else:
			variants.blue_life -= 1
			set_layer_mask(constants.LM_DONT_COLLIDE)
			set_collision_mask(constants.LM_DONT_COLLIDE)
		if life <=0 and not variants.gameover:
			if is_enemy:
				variants.blue_score += 1
				variants.red_life = 0
			else:
				variants.red_score += 1
				variants.blue_life = 0
			variants.gameover = true
			var popup = preload('res://ui/score_popup.tscn').instance()
			get_node('../').add_child(popup)
	if fire_timeout > 0:
		fire_timeout -= delta
		
	if fire2_timeout > 0:
		fire2_timeout -= delta

	if direction != 0:
		fire()
		fire2()
		shield_cool = 0.1
	if is_enemy:
		translate(Vector3(direction * speed * delta, 0, 0))

	self.get_node("Area").set_rotation_deg(Vector3(0,0, (direction if is_enemy else -direction) * 30))
	if direction == 0:
		if shield_cool > 0:
			shield_cool -= delta
			shield()
		
	else:
		get_node("Shield").hide()
		if !is_enemy:
			get_node("../ingame_ui").hide_skill_button()

	energy += delta/2
	if energy>MAX_ENERGY:
		energy = MAX_ENERGY
		
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
				
func shield():
	if shield_cool <= 0:
		is_shield = true
		#print("come " , shield_cool , "dir = ", direction)
		get_node("Shield/Sprite").set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
		get_node("Shield").show()
		if !is_enemy:
			get_node("../ingame_ui").show_skill_button()
		

func fire():
	is_shield = false
	is_hold_fire = true
	if fire_timeout > 0 && bullet_type != 4:
		return
	if is_dead:
		is_hold_fire = false
		return
	fire_timeout = fire_interval
	create_bullet(forward, Vector3(-1.5, 0, 0))
	create_bullet(forward, Vector3( 1.5, 0, 0))
	create_bullet(forward)
	
	
func fire2():
	is_shield = false
	is_hold_fire = true
	if fire2_timeout > 0 && bullet_type != 4:
		return
	if is_dead:
		is_hold_fire = false
		return
	fire2_timeout = 1
	
	create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(11)).normalized(), Vector3(1, 0, 0))
	create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(-11)).normalized(), Vector3(-1, 0, 0))
	create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(22)).normalized(), Vector3(1, 0, 0))
	create_bullet(forward.rotated(Vector3(0, 1, 0), deg2rad(-22)).normalized(), Vector3(-1, 0, 0))
	

func create_bullet(direction, width = Vector3(0,0,0)):
	var bullet
	bullet = preload('res://bullet/bullet.tscn').instance()
	bullet.add_to_group('enemy' if is_enemy else 'player')
	bullet.damage = bullet_damage
	bullet.decay_time = bullet_decay_time
	
	var bullet_mesh = bullet.get_node("MeshInstance")
	collision_shape.set_radius(bullet.get_shape(0).get_radius() * bullet_scale)
	bullet.set_shape(0, collision_shape)
	bullet.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
	bullet.translate(width)
	bullet.set_linear_velocity(direction * bullet_speed) 
	bullet.set_mass(bullet_mass)
	bullet_mesh.set_scale(bullet_mesh.get_scale() * bullet_scale)
	get_node('/root/World').add_child(bullet)

func create_laser(direction):
	if !laser:
		laser = preload('res://bullet/laser.tscn').instance()
		laser.is_enemy = is_enemy
		
		laser.set_global_transform(get_node("BulletFrom").get_global_transform().orthonormalized())
		get_node('../').add_child(laser)

func activate_skill(skill_idx, slot_num):
	var skill = constants.SKILLS[skill_idx]
	if energy - skill["energy"] <= 0:
		if not is_enemy:
			get_node("../ingame_ui").show_error_status()
		return
	energy -= skill["energy"]
	knight_skill_queue[slot_num] = knight_skill_queue[4]
	knight_skill_queue.remove(4)
	knight_skill_queue.append(skill_idx)
		
	get_node("../ingame_ui").update_ui(knight_skill_queue, is_enemy)
	if skill["name"] == "ADDON":
		call_addon()
		return
	if skill["name"] == "CHARGE":
		call_charge()
		return
	var inst = skill["scene"].instance()
	inst.add_to_group("enemy" if is_enemy else "player")
	inst.set("scene_vars", skill.scene_vars if skill.has("scene_vars") else {})
	if skill["is_player_child"]:
		add_child(inst)
		return
	get_node("../").add_child(inst)

func call_addon():
	for i in range(0, 2):
		var addon = preload('res://addon/addon.tscn').instance()
		addon.add_to_group('enemy' if is_enemy else 'player')
		var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
		var trans = get_global_transform().orthonormalized()
		trans.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
		addon.set_global_transform(trans)
		add_child(addon)
	
func call_charge():
	for i in range(0, 3):
		var charge = preload('res://charge/charge.tscn').instance()
		charge.add_to_group('enemy' if is_enemy else 'player')
		var mothership_node = get_node('../EnemyMothership') if is_enemy else get_node('../PlayerMothership')
		var trans = get_global_transform().orthonormalized()
		trans.origin.y = mothership_node.get_global_transform().orthonormalized().origin.y
		trans.origin.x = -3 + 3 * i
		trans.origin.z -= 4 + 4 * i
		charge.set_global_transform(trans)
		get_node('../').add_child(charge)
