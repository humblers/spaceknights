extends Button

var skill_type = 0
var queue_idx = 0

func _ready():
	if skill_type == constants.TURRET_FIXED_TYPE:
		set_text("FIXED")
	elif skill_type == constants.TURRET_FORWARD_TYPE:
		set_text("FORWARD")

func _on_Button_pressed():
	start.player1_skill_queue.remove(queue_idx)
	get_node("/root/main_screen").update_skill_queue()
