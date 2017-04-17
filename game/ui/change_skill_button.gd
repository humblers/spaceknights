extends Button

var skill_type = 0
var queue_idx = 0

func _ready():
	set_text(constants.SKILLS[skill_type]["name"])
	
func update_ui():
	set_text(constants.SKILLS[skill_type]["name"])

func _on_Button_pressed():
	get_node("/root/main_screen/Background/Change_BG").hide()
	

