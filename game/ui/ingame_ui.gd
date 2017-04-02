extends Control

var color_disable = Color(0,0,0,1)
var color_enable = Color(0.13,0.58,0.47,1)
var skill_queue
var skill_num
var skill = 0
var popup_cool = 0

func _ready():
	skill_queue = [] + start.player1_knight["skills"]
	get_node("Skill_status").hide()
	get_node("Error_status").hide()
	if skill_queue.size() < 5:
		skill_queue = [ 1, 2, 3, 4 , 5 ]
	
	update_ui()
	set_process(true)

func update_ui():
	for i in range(clamp(skill_queue.size() , 1, 4)):
		get_node("Skill%s" % str(i+1) ).set_text(constants.SKILLS[skill_queue[i]-1]["name"]+"\n(" + str(constants.SKILLS[skill_queue[i]-1]["energy"]) + ")")
	

func _on_skill1_pressed():
	skill = skill_queue[0]
	skill_num = 0
func _on_skill2_pressed():
	skill = skill_queue[1]
	skill_num = 1
	
func _on_skill3_pressed():
	skill = skill_queue[2]
	skill_num = 2
	
func _on_skill4_pressed():
	skill = skill_queue[3]
	skill_num = 3

func _process(delta):
	if popup_cool > 0:
		popup_cool -= delta
	else:
		popup_cool = 0
		get_node("Error_status").hide()
	if skill != 0:
		if get_node("../Player").energy - constants.SKILLS[skill-1]["energy"] <= 0:
			get_node("Error_status").set_text("NO ENERGY")
			get_node("Error_status").show()
			popup_cool = 0.3
		else:
			get_node("../Player").energy -= constants.SKILLS[skill-1]["energy"]
			if skill == constants.TURRET:
				get_node("../Player").call_turret(skill)
			elif skill == constants.DRONE:
				get_node("../Player").call_drone(skill)
			elif skill == constants.BLACKHOLE:
				get_node("../Player").summon_blackhole()
			elif skill == constants.ADDON:
				get_node("../Player").call_addon(skill)
			elif skill == constants.CHARGE:
				get_node("../Player").call_charge(skill)
			skill_queue[skill_num] = skill_queue[4]
			skill_queue.remove(4)
			skill_queue.append(skill)
			
		skill = 0
		update_ui()
	#