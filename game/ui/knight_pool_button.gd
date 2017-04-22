extends Button
var text = "null"
var knight_type = 0

func _ready():
	set_text(constants.KNIGHTS[knight_type]["type"])

func update_ui():
	set_text(constants.KNIGHTS[knight_type]["type"])

func _on_Button1_pressed():
	get_node("../../../../Change_knight").set_change_knight(knight_type)
	
		
