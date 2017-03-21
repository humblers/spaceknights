extends Control

func _ready():
	get_node("blue_team").set_text("Blue Team : " + str(start.blue_score) + " WIN")
	get_node("red_team").set_text("Red Team : " + str(start.red_score) + " WIN")
	set_process_unhandled_input(true)
	update_skill_queue()
	
func _on_play_pressed():
	get_tree().change_scene("res://main.tscn")

func _unhandled_input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()

func _on_turret_fixed_pressed():
	var queue = start.player1_skill_queue
	if queue.size() >= constants.SKILL_QUEUE_LEN:
		return
	queue.append(constants.TURRET_FIXED_TYPE)
	update_skill_queue()

func _on_turret_forward_pressed():
	var queue = start.player1_skill_queue
	if queue.size() >= constants.SKILL_QUEUE_LEN:
		return
	queue.append(constants.TURRET_FORWARD_TYPE)
	update_skill_queue()

func update_skill_queue():
	var button_parent = get_node("skill_panel/scroll/skill_queue")
	for prev_button in button_parent.get_children():
		prev_button.queue_free()
	var skill_tscn = preload("res://ui/skill_button.tscn")
	for i in range(start.player1_skill_queue.size()):
		var button = skill_tscn.instance()
		button.skill_type = start.player1_skill_queue[i]
		button.queue_idx = i
		button_parent.add_child(button)
