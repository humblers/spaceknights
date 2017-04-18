extends Button
var text = "null"
var knight_type = 0

func _ready():
	set_text(constants.KNIGHTS[knight_type]["type"])

func update_ui():
	set_text(constants.KNIGHTS[knight_type]["type"])

func _on_Button1_pressed():
	get_node("/root/main_screen/Background/Change_knight").show()
	get_node("/root/main_screen/Background/Change_knight/Button").knight_type = knight_type
	get_node("/root/main_screen/Background/Change_knight/Button").update_ui()
		
