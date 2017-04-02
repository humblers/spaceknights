extends Control

var color_disable = Color(0,0,0,1)
var color_enable = Color(0.13,0.58,0.47,1)
var skill_queue
var slot_num
var skill_idx = 0
var popup_cool = 0

func _ready():
	skill_queue = [] + variants.player1_knight["skills"]
	get_node("Skill_status").hide()
	get_node("Error_status").hide()
	if skill_queue.size() < 5:
		skill_queue = [ 1, 2, 3, 4, 5 ]
	
	update_ui()
	set_process(true)

func update_ui():
	for i in range(3):
		get_node("Skill%d" % i+1).set_text(constants.SKILLS[skill_queue[i]-1]["name"]+"\n(" + str(constants.SKILLS[skill_queue[i]-1]["energy"]) + ")")

func _on_skill1_pressed():
	skill_idx = skill_queue[0]
	slot_num = 0

func _on_skill2_pressed():
	skill_idx = skill_queue[1]
	slot_num = 1
	
func _on_skill3_pressed():
	skill_idx = skill_queue[2]
	slot_num = 2
	
func _on_skill4_pressed():
	skill_idx = skill_queue[3]
	slot_num = 3

func _process(delta):
	if popup_cool > 0:
		popup_cool -= delta
	else:
		popup_cool = 0
		get_node("Error_status").hide()
	if skill_idx != 0:
		if get_node("../Player").energy - constants.SKILLS[skill_idx-1]["energy"] <= 0:
			get_node("Error_status").set_text("NO ENERGY")
			get_node("Error_status").show()
			popup_cool = 0.3
		else:
			var player_node = get_node("../Player")
			player_node.energy -= constants.SKILLS[skill_idx-1]["energy"]
			player_node.activate_skill(skill_idx)
			skill_queue[slot_num] = skill_queue[4]
			skill_queue.remove(4)
			skill_queue.append(skill_idx)
			
		skill_idx = 0
		update_ui()
	#