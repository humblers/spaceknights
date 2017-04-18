extends Button

var knight_type = 0

func _ready():
	set_text(constants.KNIGHTS[knight_type]["type"])
	
func update_ui():
	set_text(constants.KNIGHTS[knight_type]["type"])

func _on_Button_pressed():
	get_node("/root/main_screen/Background/Change_knight").hide()
	

