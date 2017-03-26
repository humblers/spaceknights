extends Control

func _ready():
	get_node("blue_team").set_text("Blue Team : " + str(start.blue_score) + " WIN")
	get_node("red_team").set_text("Red Team : " + str(start.red_score) + " WIN")
	set_process_input(true)
	update_skill_queue()
	
func _on_play_pressed():
	get_tree().change_scene("res://main.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()

func update_skill_panel(player):
	var button_parent = get_node("picked_skill_%s/scroll/skill_queue" % player)
	for prev_button in button_parent.get_children():
		prev_button.queue_free()
	var skill_tscn = preload("res://ui/skill_button.tscn")
	for i in range(start.get("%s_skill_queue" % player).size()):
		var button = skill_tscn.instance()
		button.skill_type = start.player1_skill_queue[i]
		button.queue_idx = i
		button_parent.add_child(button)

func update_skill_queue(players=null):
	if players == null:
		players = ["player1", "player2"]
	for player in players:
		update_skill_panel(player)
