extends Button
var text = "null"
var skill_type = 0

func _ready():
	set_text(constants.SKILLS[skill_type]["name"])

func update_ui():
	set_text(constants.SKILLS[skill_type]["name"])

		
