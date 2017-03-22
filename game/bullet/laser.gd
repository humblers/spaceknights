extends StaticBody

var damage = 1
var is_enemy = false
var is_penetrate = false
var initial_scale
var time = 0
var creating_time = 30
var laser_scale = 1

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
	time += delta*10
	laser_scale = clamp(time/creating_time, 0.1, 1)
	var material
	material = get_node("laser_cube").get_material_override()
	get_node("laser_cube").set_scale(Vector3(laser_scale , 1, 40))
		
	var laser_color = (sin(time)+1)/2*0.6+0.2
	if is_enemy:
		material.set_parameter(material.PARAM_DIFFUSE,Color(laser_color+0.5,laser_color,laser_color,laser_color+0.5))
	else:
		material.set_parameter(material.PARAM_DIFFUSE,Color(laser_color,laser_color,laser_color+0.5,laser_color+0.5))
	