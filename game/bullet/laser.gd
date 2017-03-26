extends KinematicBody

var damage = 3
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

func _on_Laser_body_enter( body ):
	if is_enemy:
		if body.get_name() == 'Player':
			is_player_knight_damaged = true
		if body.get_name() == 'PlayerMothership':
			is_player_mother_damaged = true
	else:
		if body.get_name() == 'Enemy':
			is_enemy_knight_damaged = true
		if body.get_name() == 'EnemyMothership':
			is_enemy_mother_damaged = true
	
func _on_Laser_body_exit( body ):
	if is_enemy:
		if body.get_name() == 'Player':
			is_player_knight_damaged = false
		if body.get_name() == 'PlayerMothership':
			#is_player_mother_damaged = false
			pass
	else:
		if body.get_name() == 'Enemy':
			is_enemy_knight_damaged = false
		if body.get_name() == 'EnemyMothership':
			#is_enemy_mother_damaged = false
			pass

func give_damage(damage):
	if is_enemy:
		if is_player_knight_damaged:
			if get_node('../Player').hp > 0:
				get_node('../Player').hp -= damage
				if get_node('../Player').hp < 0:
					get_node('../Player').hp = 0
				get_node('../Player').update_ui()
		if is_player_mother_damaged:
			if get_node('../PlayerMothership').hp > 0:
				get_node('../PlayerMothership').hp -= damage
				if get_node('../PlayerMothership').hp < 0:
					get_node('../PlayerMothership').hp = 0
				get_node('../PlayerMothership').update_ui()
			
	else:
		if is_enemy_knight_damaged:
			if get_node('../Enemy').hp > 0:
				get_node('../Enemy').hp -= damage
				if get_node('../Enemy').hp < 0:
					get_node('../Enemy').hp = 0
				get_node('../Enemy').update_ui()
		if is_enemy_mother_damaged:
			if get_node('../EnemyMothership').hp > 0:
				get_node('../EnemyMothership').hp -= damage
				if get_node('../EnemyMothership').hp < 0:
					get_node('../EnemyMothership').hp = 0
				get_node('../EnemyMothership').update_ui()
				
func _ready():
	var material = get_node("laser_cube").get_material_override()
	material.set_parameter(material.PARAM_DIFFUSE,Color(1,1,1,0.5))
	get_node("laser_cube").set_material_override(material)
	if is_enemy:
		add_to_group('enemy_Laser')
	else :
		add_to_group('player_Laser')
	set_process(true)
		
func _process(delta):
	time += delta*2
	laser_scale = clamp(time/creating_time, 0.1, 1)
	var material
	material = get_node("laser_cube").get_material_override()
	get_node("laser_cube").set_scale(Vector3(laser_scale , 1, 40))
		
	var laser_color = (sin(time)+1)/2*0.6+0.2
	if is_enemy:
		material.set_parameter(material.PARAM_DIFFUSE,Color(laser_color+0.5,laser_color,laser_color,laser_color+0.5))
	else:
		material.set_parameter(material.PARAM_DIFFUSE,Color(laser_color,laser_color,laser_color+0.5,laser_color+0.5))
	
	give_damage(damage*laser_scale)
	

