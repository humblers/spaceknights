extends Button

var skill_type = int(-1)
var queue_idx = 0

func _ready():
	if skill_type < 0:
		set_text("...")
	else:
		set_text(constants.SKILLS[skill_type]["name"])
	
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
	else:
		get_node("../../AMMO_collection").show()
		get_node("../../Knight_collection").hide()
		get_node("../../Change_knight").hide()

	
func _process(delta):
	"""	
	if is_dead:
		if regen_timeout > 0:
			regen_timeout -= delta
		else:
			is_dead = false
			hp = HP_MAX
			update_ui()
			regen_timeout = 0
			self.show()
	
	skill_remain -= delta
	"""
	print("haha")
	if get_parent().is_changeable:
		set_rotation_deg(1)