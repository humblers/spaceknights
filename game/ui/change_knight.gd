extends Panel

var knight_type = 0

func _ready():
	get_node("Knight_name/Label").set_text(constants.KNIGHTS[knight_type]["type"])
	get_node("Knight_thumb").knight_type = knight_type
	get_node("Knight_thumb").update_ui()
	self.hide()
	
func update_ui():
	get_node("Knight_name/Label").set_text(constants.KNIGHTS[knight_type]["type"])
	get_node("Knight_thumb").knight_type = knight_type
	get_node("Knight_thumb").update_ui()
	

func _on_Button_no_pressed():
	self.hide()

func _on_Button_yes_pressed():
	self.hide()
	get_node("../../").change_knight(knight_type)
	
func set_change_knight(index):
	self.show()
	knight_type = index
	update_ui()
	