extends Button

var skill_type = int(0)
var queue_idx = 0
var is_changeable = false

func _ready():
	set_text(constants.SKILLS[skill_type]["name"])
	set_ignore_mouse(true)
	
func update_ui():
	set_text(constants.SKILLS[skill_type]["name"])

func _on_Button_pressed():
	get_node("/root/main_screen").change_skill(skill_type, queue_idx)
	update_ui()
	
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