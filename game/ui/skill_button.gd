extends Button

var skill_type = int(-1)
var queue_idx = 0
var is_changeable = false

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
	if get_node("/root/main_screen/Background/Change_skill").is_visible():
		get_node("/root/main_screen").change_skill(skill_type, queue_idx)
		update_ui()
		get_node("/root/main_screen/Background/Change_skill").hide()
	else:
		get_node("/root/main_screen/Background/AMMO_collection").show()
		get_node("/root/main_screen/Background/Knight_collection").hide()
		get_node("/root/main_screen/Background/Change_knight").hide()

	
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
	if is_changeable:
		set_ignore_mouse(false)
		set_rotation_deg(1)