extends Button

var skill_type = 0
var queue_idx = 0

func _ready():
	set_text(constants.SKILLS[skill_type]["name"])

func _on_Button_pressed():
	get_node("../../../../").remove_skill(queue_idx)
