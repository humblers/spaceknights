extends Button
var text = "null"
var skill_type = 0

func _ready():
	set_text(constants.SKILLS[skill_type]["name"])

func update_ui():
	set_text(constants.SKILLS[skill_type]["name"])

func _on_Button1_pressed():
	get_node("../../../../Change_skill").set_change_skill(skill_type)
