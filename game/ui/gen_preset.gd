extends Control

#onready var presets = start.preset_knights
onready var presets = {
	"dummy" : {},
}

func _ready():
	initialize_knight_type_button()
	initialize_knight_skill_button()
	update_preset_button()

func initialize_knight_type_button():
	var pick_button = get_node("pick_type")
	for i in range(constants.KNIGHTS.size()):
		pick_button.add_item(constants.KNIGHTS[i]["type"], i)

func initialize_knight_skill_button():
	var pick_button = get_node("pick_skill_panel/pick_skill")
	pick_button.add_item("turret", constants.TURRET)
	pick_button.add_item("drone", constants.DRONE)
	pick_button.add_item("blackhole", constants.BLACKHOLE)
	pick_button.add_item("addon", constants.ADDON)
	pick_button.add_item("charge", constants.CHARGE)

func update_preset_button():
	var pick_button = get_node("pick_preset")
	pick_button.clear()
	pick_button.add_item("dummy", 0)
	pick_button.add_item("new", presets.size())

func get_current_skill():
	return get_node("pick_skill_panel/pick_skill").get_selected_ID()

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

func _on_add_skill_pressed():
	pass # replace with function body

func _on_pick_preset_item_selected( ID ):
	print(ID)
	pass # replace with function body
