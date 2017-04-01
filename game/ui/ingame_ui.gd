extends Control

var color_disable = Color(0,0,0,1)
var color_enable = Color(0.13,0.58,0.47,1)
var skill_num

func _ready():
	print(get_node("Skill1").get_modulate())
	get_node("Skill1").set_modulate(color_disable)
	get_node("Skill2").set_modulate(color_disable)
	get_node("Skill3").set_modulate(color_disable)
	get_node("Skill4").set_modulate(color_disable)
	get_node("Skill5").set_modulate(color_disable)
	get_node("Skill_status").hide()
	get_node("Error_status").hide()
	set_process(true)

func enable_skill(selected):
	get_node("Skill1").set_modulate(color_disable)
	get_node("Skill2").set_modulate(color_disable)
	get_node("Skill3").set_modulate(color_disable)
	get_node("Skill4").set_modulate(color_disable)
	get_node("Skill5").set_modulate(color_disable)
	get_node("Skill%s" %selected).set_modulate(color_enable)

func _process(delta):
	#get_node("../Player").
	#print('pos = ', get_node('../Camera').unproject_position(get_node("../Player").get_global_transform().origin))
	
	var player_x = get_node('../Camera').unproject_position(get_node("../Player").get_global_transform().origin).x
	if get_node("Skill1").get_pos().x <= player_x && player_x < get_node("Skill2").get_pos().x:
		skill_num = constants.TURRET
	if get_node("Skill2").get_pos().x <= player_x && player_x < get_node("Skill3").get_pos().x:
		skill_num = constants.DRONE
	if get_node("Skill3").get_pos().x <= player_x && player_x < get_node("Skill4").get_pos().x:
		skill_num = constants.BLACKHOLE
	if get_node("Skill4").get_pos().x <= player_x && player_x < get_node("Skill5").get_pos().x:
		skill_num = constants.ADDON
	if get_node("Skill5").get_pos().x <= player_x && player_x:
		skill_num = constants.CHARGE
	enable_skill(skill_num)
		
		
	#print(player_x ,' = ' , get_node("Skill1").get_pos().x , ' = ', get_node("Skill2").get_pos().x)
	#get_node('../Camera').unproject_position(get_global_transform().origin)