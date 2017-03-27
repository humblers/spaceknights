extends Panel

func _ready():
	var pick_button = get_node("pick_skill")
	pick_button.add_item("turret", constants.TURRET)
	pick_button.add_item("drone", constants.DRONE)
	pick_button.add_item("blackhole", constants.BLACKHOLE)
	pick_button.add_item("addon", constants.ADDON)
	pick_button.add_item("charge", constants.CHARGE)

func get_current_skill():
	return get_node("pick_skill").get_selected_ID()

func add_skill_to_queue(queue, skill):
	if queue.size() >= constants.SKILL_QUEUE_LEN:
		return
	queue.append(skill)

func _on_add_to_player1_pressed():
	add_skill_to_queue(start.player1_skill_queue, get_current_skill())
	get_parent().update_skill_queue(["player1"])

func _on_add_to_player2_pressed():
	add_skill_to_queue(start.player2_skill_queue, get_current_skill())
	get_parent().update_skill_queue(["player2"])
