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
	get_node("../Change_skill").hide()
	get_node("../AMMO_collection").hide()
	get_node("../Knight_collection").show()