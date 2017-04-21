	func set_change_skill():
		self.show()
		get_node("Button").skill_type = skill_type
		get_node("Button").update_ui()