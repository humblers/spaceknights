extends Control

func _ready():
	get_node("blue_team").set_text("Blue Team : " + str(Globals.get("blue_result")) + " WIN")
	get_node("red_team").set_text("Red Team : " + str(Globals.get("red_result")) + " WIN")
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

var current = []
func update_skill_queue():
	for prev_button in current:
		prev_button.queue_free()
	current = []
	var skill_tscn = preload("res://ui/skill_button.tscn")
	for i in range(start.player1_skill_queue.size()):
		var button = preload("res://ui/skill_button.tscn").instance()
		var skill = start.player1_skill_queue[i]
		if skill == constants.TURRET_FIXED_TYPE:
			button.set_text("FIXED")
		elif skill == constants.TURRET_FORWARD_TYPE:
			button.set_text("FORWARD")
		get_node("skill_panel/scroll/skill_queue").add_child(button)
		current.append(button)
