extends Button

var player = ""
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
	start.get("%s_skill_queue" % player).remove(queue_idx)
	get_node("/root/main_screen").update_skill_queue()
