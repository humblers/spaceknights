func _ready():
	self.hide()
	
func set_change_skill(skill_type):
	self.show()
	get_node("Button").skill_type = skill_type
	get_node("Button").update_ui()
	get_node("../Skill_grid").is_changeable = true
	
func _on_Button_pressed():
	self.hide()
	get_node("../Skill_grid").is_changeable = false