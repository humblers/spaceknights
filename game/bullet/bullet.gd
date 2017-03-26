extends RigidBody

var HP_MAX = 1000
var damage = 1
var hp = 1
var life_timer = 0
var decay_time = 1
var is_enemy = false
var is_cannon = false
var is_cannon_dead = false
var is_mass = false
var is_mass_dead = false
var damaged_scale = float(1)
var collision_shape = SphereShape.new()
var initial_scale
var initial_radius

func _ready():
	if is_cannon:
		if is_enemy:
			add_to_group('enemy_Cannon')
		else:
			add_to_group('player_Cannon')
			#var material = get_node("MeshInstance").get_mesh().surface_get_material(0)
			
			#material.set_parameter(material.PARAM_EMISSION,Color(0,0,0.2,1))
			
			#get_node("MeshInstance").set_material_override(material)
	else:
		if is_enemy:
			add_to_group('enemy_Bullet')
		else:
			add_to_group('player_Bullet')
			var material = get_node("MeshInstance").get_mesh().surface_get_material(0)
			
			material.set_parameter(material.PARAM_EMISSION,Color(0,0,0.2,1))
			
			get_node("MeshInstance").set_material_override(material)
		
	initial_scale = get_node("MeshInstance").get_scale()
	initial_radius = self.get_shape(0).get_radius()
	set_process(true)

func _process(delta):
	life_timer += delta
	if life_timer > decay_time:
		on_timeout_complete()
		life_timer = 0
		
	if is_cannon_dead:
		damaged_scale = damaged_scale * 0.1
		var bullet_mesh = get_node("MeshInstance")
		if damaged_scale > 0.1:
			collision_shape.set_radius(initial_radius * damaged_scale)
			self.set_shape(0, collision_shape)
			bullet_mesh.set_scale(initial_scale * damaged_scale)
		
	if is_mass_dead:
		damaged_scale = damaged_scale * 0.5
		var bullet_mesh = get_node("MeshInstance")
		if damaged_scale > 0.1:
			collision_shape.set_radius(initial_radius * damaged_scale)
			self.set_shape(0, collision_shape)
			bullet_mesh.set_scale(initial_scale * damaged_scale)
			
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
	
	"""
	if (body.is_in_group("enemy_Bullet") and not is_enemy) 
	or (body.is_in_group("player_Bullet") and is_enemy):
		take_damage(body.damage)
	"""
	
func take_damage(damage):
	hp = clamp(hp - damage, 0, HP_MAX)
	if hp <= 0 :
		if is_cannon:			
			if damaged_scale < 0.2:
				queue_free()
			else:
				is_cannon_dead = true
		elif !is_mass:
			queue_free()
			
		if is_mass:
			if damaged_scale < 0.2:
				queue_free()
			else:
				is_mass_dead = true
		elif !is_cannon:
			queue_free()
		
	if is_cannon && !is_cannon_dead:
		damaged_scale = float(hp)/float(HP_MAX)
		if damaged_scale < 0.1:
			queue_free()
		else:
			var bullet_mesh = get_node("MeshInstance")
			collision_shape.set_radius(initial_radius * damaged_scale)
			self.set_shape(0, collision_shape)
			bullet_mesh.set_scale(initial_scale * damaged_scale)
			
	if is_mass && !is_mass_dead:
		damaged_scale = float(hp)/float(HP_MAX)
		if damaged_scale < 0.1:
			queue_free()
		else:
			var bullet_mesh = get_node("MeshInstance")
			collision_shape.set_radius(initial_radius * damaged_scale)
			self.set_shape(0, collision_shape)
			bullet_mesh.set_scale(initial_scale * damaged_scale)