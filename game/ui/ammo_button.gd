extends Button
var text = "null"
var skill_type = 0

func _ready():
	set_text(constants.SKILLS[skill_type]["name"])

func update_ui():
	set_text(constants.SKILLS[skill_type]["name"])

func _on_Button1_pressed():
	get_node("/root/main_screen/Background/Change_skill").show()
	get_node("/root/main_screen/Background/Change_skill/Button").skill_type = skill_type
	get_node("/root/main_screen/Background/Change_skill/Button").update_ui()
		
