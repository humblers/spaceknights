extends Panel

var knight_type = 0

func _ready():
	get_node("Knight_name/Label").set_text(constants.KNIGHTS[knight_type]["type"])
	get_node("Knight_thumb").knight_type = knight_type
	get_node("Knight_thumb").update_ui()
	
func update_ui():
	get_node("Knight_name/Label").set_text(constants.KNIGHTS[knight_type]["type"])
	get_node("Knight_thumb").knight_type = knight_type
	get_node("Knight_thumb").update_ui()
	

func _on_Button_pressed():
	get_node("/root/main_screen/Background/Change_knight").hide()
	

