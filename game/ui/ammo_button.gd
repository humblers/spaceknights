extends Button
var text = "null"
var skill_type = 0
var queue_idx = 0

func _ready():
	set_text(constants.SKILLS[skill_type]["name"])

func update_ui():
	set_text(constants.SKILLS[skill_type]["name"])

func _on_Button1_pressed():
	get_node("/root/main_screen/Background/Change_BG").show()
	get_node("/root/main_screen/Background/Change_BG/Button").skill_type = skill_type
	get_node("/root/main_screen/Background/Change_BG/Button").queue_idx = queue_idx
	get_node("/root/main_screen/Background/Change_BG/Button").update_ui()
	
	for i in range(8):
		get_node("/root/main_screen/Background/Skill_grid/Button%d" % (i+1)).set_ignore_mouse(false)
		
