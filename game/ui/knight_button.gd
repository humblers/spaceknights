extends Button

var knight_type = -1

func _ready():
	if knight_type < 0:
		set_text("...")
	else:
		set_text(constants.KNIGHTS[knight_type]["type"])
	
func update_ui():
	if knight_type < 0:
		set_text("...")
	else:
		set_text(constants.KNIGHTS[knight_type]["type"])

func _on_Knight_type_pressed():
	get_node("/root/main_screen/Background/Change_skill").hide()
	get_node("/root/main_screen/Background/AMMO_collection").hide()
	get_node("/root/main_screen/Background/Knight_collection").show()