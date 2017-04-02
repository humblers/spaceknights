extends Button

var skill_type = 0
var queue_idx = 0

func _ready():
	if skill_type == constants.TURRET:
		set_text("TURRET")
	elif skill_type == constants.DRONE:
		set_text("DRONE")
	elif skill_type == constants.BLACKHOLE:
		set_text("BLACKHOLE")
	elif skill_type == constants.ADDON:
		set_text("ADDON")
	elif skill_type == constants.CHARGE:
		set_text("CHARGE")

func _on_Button_pressed():
	get_node("../../../../").remove_skill(queue_idx)
