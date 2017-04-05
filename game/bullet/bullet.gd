extends RigidBody

var HP_MAX = 1000
var damage = 1
var hp = 1
var life_timer = 0
var decay_time = 1
var is_enemy = false
var is_critical = false
var is_cannon = false
var is_cannon_dead = false
var is_mass = false
var is_mass_dead = false
var damaged_scale = float(1)
var collision_shape = SphereShape.new()
var initial_scale
var initial_radius
var material_01 = FixedMaterial.new()
var material_02 = FixedMaterial.new()
export var is_2d = false

var time = 0

func _ready():
	if is_cannon:
		if is_enemy:
			add_to_group('enemy_Cannon')
			set_layer_mask(constants.LM_ENEMY)
			set_collision_mask(constants.LM_PLAYER)
		else:
			add_to_group('player_Cannon')
			set_layer_mask(constants.LM_PLAYER)
			set_collision_mask(constants.LM_ENEMY)
	else:
		if is_enemy:
			add_to_group('enemy_Bullet')
			set_layer_mask(constants.LM_ENEMY)
			set_collision_mask(constants.LM_PLAYER)
	
		else:
			add_to_group('player_Bullet')
			set_layer_mask(constants.LM_PLAYER)
			set_collision_mask(constants.LM_ENEMY)
			material_01.set_parameter(material_01.PARAM_DIFFUSE,Color(0.2,0.2,0.7,1))
			get_node("MeshInstance").set_material_override(material_01)
			
		if is_critical:
			material_02.set_parameter(material_02.PARAM_DIFFUSE,Color(0,1,0,1))
			get_node("MeshInstance").set_material_override(material_02)
		
	initial_scale = get_node("MeshInstance").get_scale()
	initial_radius = self.get_shape(0).get_radius()
	
	if is_2d:
		if get_node("MeshInstance").is_visible():
			get_node("MeshInstance").hide()
		get_node("Node2D").show()
	else:
		if get_node("Node2D").is_visible():
			get_node("MeshInstance").show()
			get_node("Node2D").hide()
	set_process(true)

func _process(delta):
	if is_2d:
		get_node("Node2D/Sprite").set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
		#print(get_node('../Camera').unproject_position(get_global_transform().origin))
	life_timer += delta
	if life_timer > decay_time:
		on_timeout_complete()
		life_timer = 0
		
	if is_cannon_dead:
		damaged_scale = damaged_scale * 0.9
		var bullet_mesh = get_node("MeshInstance")
		if damaged_scale > 0.3:
			collision_shape.set_radius(initial_radius * damaged_scale)
			self.set_shape(0, collision_shape)
			bullet_mesh.set_scale(initial_scale * damaged_scale)
		else:
			queue_free()
		
	if is_mass_dead:
		damaged_scale = damaged_scale * 0.9
		var bullet_mesh = get_node("MeshInstance")
		if damaged_scale > 0.3:
			collision_shape.set_radius(initial_radius * damaged_scale)
			self.set_shape(0, collision_shape)
			bullet_mesh.set_scale(initial_scale * damaged_scale)
		else:
			queue_free()
	
	time += delta*20
	if is_critical:
		var color = (sin(time)+1)/2*0.5
		material_02.set_parameter(material_02.PARAM_DIFFUSE,Color(color+0.5,color+0.5,color/2,color+0.5))
		get_node("MeshInstance").set_material_override(material_02)
		#print('who am i = ', self, 'v = ',self.get_linear_velocity())
		
		#if sin(time) > 0.99:
		#	print('who am i = ', self, 'z = ', self.get_translation().z , ' time = ', sin(time)) 
		
func on_timeout_complete():
	#pass
	queue_free()


func _on_Bullet_body_enter( body ):
		
	if is_enemy:
		if body.is_in_group("player_Bullet") && is_cannon:
			take_damage(body.damage)
		elif body.is_in_group("player_Cannon"):
			if is_cannon:
				take_damage(body.damage)
			else:
				queue_free()
	else:
		if body.is_in_group("enemy_Bullet") && is_cannon:
			take_damage(body.damage)
		elif body.is_in_group("enemy_Cannon"):
			if is_cannon:
				take_damage(body.damage)
			else:
				queue_free()
				
	if is_enemy:
		if body.is_in_group("player_Bullet") && is_mass:
			take_damage(body.damage)
		elif body.is_in_group("player_Bullet") && body.is_mass:
			if is_mass:
				take_damage(body.damage)
			else:
				queue_free()
	else:
		if body.is_in_group("enemy_Bullet") && is_mass:
			take_damage(body.damage)
		elif body.is_in_group("enemy_Bullet") && body.is_mass:
			if is_mass:
				take_damage(body.damage)
			else:
				queue_free()
	
func take_damage(damage):
	hp = clamp(hp - damage, 0, HP_MAX)
	if hp <= 0 :
		if is_cannon:			
			if damaged_scale < 0.3:
				queue_free()
			else:
				is_cannon_dead = true
		elif !is_mass:
			queue_free()
			
		if is_mass:
			if damaged_scale < 0.3:
				queue_free()
			else:
				is_mass_dead = true
		elif !is_cannon:
			queue_free()
		
	if is_cannon && !is_cannon_dead:
		damaged_scale = float(hp)/float(HP_MAX)
		if damaged_scale < 0.3:
			queue_free()
		else:
			pass
			"""
			var bullet_mesh = get_node("MeshInstance")
			collision_shape.set_radius(initial_radius * damaged_scale)
			self.set_shape(0, collision_shape)
			bullet_mesh.set_scale(initial_scale * damaged_scale)
			"""
			
	if is_mass && !is_mass_dead:
		damaged_scale = float(hp)/float(HP_MAX)
		if damaged_scale < 0.3:
			queue_free()
		else:
			var bullet_mesh = get_node("MeshInstance")
			collision_shape.set_radius(initial_radius * damaged_scale)
			self.set_shape(0, collision_shape)
			bullet_mesh.set_scale(initial_scale * damaged_scale)