extends KinematicBody

var damage = 1.5
var is_enemy = false
var is_enemy_knight_damaged = false
var is_enemy_mother_damaged = false
var is_player_knight_damaged = false
var is_player_mother_damaged = false

var is_penetrate = false
var initial_scale
var time = 0
var creating_time = 30
var laser_scale = 1
var damaged_bodies = []
var hp

func _on_Laser_body_enter( body ):
	if is_enemy && body.get_layer_mask() != constants.LM_PLAYER:
		return
	if !is_enemy && body.get_layer_mask() != constants.LM_ENEMY:
		return
	if is_enemy && body.is_enemy:
		return
	if !is_enemy && !body.is_enemy:
		return
	if 'Bullet' in body.get_name():
		if !body.is_mass:
			return
	damaged_bodies.append(body)
	
func _on_Laser_body_exit( body ):
	if is_enemy && body.get_layer_mask() != constants.LM_PLAYER:
		return
	if !is_enemy && body.get_layer_mask() != constants.LM_ENEMY:
		return
	if is_enemy && body.is_enemy:
		return
	if !is_enemy && !body.is_enemy:
		return
	if 'Bullet' in body.get_name():
		if !body.is_mass:
			return
	damaged_bodies.erase(body)
		
func give_damage(damage):
	for i in range(damaged_bodies.size()):
		if weakref(damaged_bodies[i]).get_ref():
			if damaged_bodies[i].get("hp"):
				if damaged_bodies[i].hp > 0:
					damaged_bodies[i].hp -= damage
					if damaged_bodies[i].get_name() == 'Drone':
						damaged_bodies[i].update_ui()
					if damaged_bodies[i].get_name() == 'Turret':
						damaged_bodies[i].update_ui()
					if 'Bullet' in damaged_bodies[i].get_name():
						damaged_bodies[i].take_damage(damage)
					if 'Rocket' in damaged_bodies[i].get_name():
						damaged_bodies[i].take_damage(damage)
				else:
					damaged_bodies[i].hp = 0
		
			
func _ready():
	var material = get_node("MeshInstance").get_mesh().surface_get_material(0)
	material.set_parameter(material.PARAM_DIFFUSE,Color(1,1,1,0.5))
	get_node("MeshInstance").set_material_override(material)
	if is_enemy:
		add_to_group('enemy_Laser')
	else :
		add_to_group('player_Laser')	
		
	set_process(true)
		
func _process(delta):
	time += delta*2
	laser_scale = clamp(time/creating_time, 0.1, 1)
	var material
	material = get_node("MeshInstance").get_material_override()
	get_node("MeshInstance").set_scale(Vector3(laser_scale * 0.05 , 0.05, 0.2))
		
	var laser_color = (sin(time)+1)/2*0.6+0.2
	if is_enemy:
		material.set_parameter(material.PARAM_DIFFUSE,Color(laser_color+0.5,laser_color,laser_color,laser_color+0.5))
		get_node("MeshInstance").set_material_override(material)
	else:
		material.set_parameter(material.PARAM_DIFFUSE,Color(laser_color,laser_color,laser_color+0.5,laser_color+0.5))
		get_node("MeshInstance").set_material_override(material)
	
	give_damage(damage*laser_scale)
	get_node("../PlayerMothership").update_ui()
	get_node("../EnemyMothership").update_ui()
	

