extends Button

var skill_type = int(-1)
var queue_idx = 0
var delta_timeout = 0
var rot_time = 0

func _ready():
	if skill_type < 0:
		set_text("...")
	else:
		set_text(constants.SKILLS[skill_type]["name"])
	set_process(true)
	
func update_ui():
	if skill_type < 0:
		set_text("...")
	else:
		set_text(constants.SKILLS[skill_type]["name"])

func _on_Button_pressed():
	if get_node("../../Change_skill").is_visible():
		get_node("../../../").change_skill(skill_type, queue_idx)
		update_ui()
		get_node("../../Change_skill").hide()
		get_parent().is_changeable = false
	else:
		get_node("../../AMMO_collection").show()
		get_node("../../Knight_collection").hide()
		get_node("../../Change_knight").hide()
		get_parent().is_changeable = false

	
func _process(delta):
	if get_parent().is_changeable:
		rot_time += delta
		set_rotation_deg(sin(rot_time*50)*2)
	else:
		rot_time = 0
		set_rotation_deg(0)
	
	