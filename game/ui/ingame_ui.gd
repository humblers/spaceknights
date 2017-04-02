extends Control

var color_disable = Color(0,0,0,1)
var color_enable = Color(0.13,0.58,0.47,1)
var popup_cool = 0

var skill1
var skill2
var skill3
var skill4

func _ready():
	get_node("Skill_status").hide()
	get_node("Error_status").hide()
	set_process(true)

func update_ui(skill_queue):
	for i in range(4):
		var skill = constants.SKILLS[skill_queue[i]]
		get_node("Skill%d" % [i+1]).set_text("%s\n(%s)" % [skill["name"], skill["energy"]])
		set("skill%d" % [i+1], skill_queue[i])

func _on_skill1_pressed():
	get_node("../Player").activate_skill(skill1, 0)

func _on_skill2_pressed():
	get_node("../Player").activate_skill(skill2, 1)
	
func _on_skill3_pressed():
	get_node("../Player").activate_skill(skill3, 2)
	
func _on_skill4_pressed():
	get_node("../Player").activate_skill(skill4, 3)

func _process(delta):
	if popup_cool > 0:
		popup_cool -= delta
	else:
		popup_cool = 0
		get_node("Error_status").hide()
		
func show_error_status():
	get_node("Error_status").set_text("NO ENERGY")
	get_node("Error_status").show()
	popup_cool = 0.3
