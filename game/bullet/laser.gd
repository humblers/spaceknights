extends StaticBody

var material1
var material2
var HP_MAX = 1000
var damage = 1
var hp = 1
var life_timer = 0
var decay_time = 1
var is_enemy = false
var is_heavy_mass = false
var is_heavy_mass_dead = false
var damaged_scale = float(1)
var collision_shape = SphereShape.new()
var initial_scale
var initial_radius

func _ready():
	material1 = get_node("laser").get_material_override()
	#print(material1)
	material1.set_parameter(material1.PARAM_EMISSION,Color(1,0,0,1))
	
	
	var i = float(230)/float(250)
	#print(i)
	set_process(true)
		
func _process(delta):
	pass
	
func finish():
	queue_free()