extends Control

var preset_list
var cur_preset

func _ready():
	initialize_knight_type_button()
	initialize_knight_skill_button()
	build_preset_pick_button()

func initialize_knight_skill_button():
	var pick_button = get_node("pick_skill_panel/pick_skill")
	for i in range(constants.SKILLS.size()):
		pick_button.add_item(constants.SKILLS[i]["name"], i)

func initialize_knight_type_button():
	var pick_button = get_node("pick_type")
	for i in range(constants.KNIGHTS.size()):
		pick_button.add_item(constants.KNIGHTS[i]["type"], i)

func build_preset_pick_button():
	preset_list = []
	var clone = {}
	clone.parse_json(variants.preset_knights.to_json())
	for key in clone:
		var preset = clone[key]
		preset["key"] = key
		preset_list.append(preset)
	preset_list.append({
		"key" : "new",
		"type" : get_node("pick_type").get_selected(),
		"skills" : []
	})
	var pick_button = get_node("pick_preset")
	pick_button.clear()
	for i in range(preset_list.size()):
		pick_button.add_item(preset_list[i]["key"], i)
	update_preset()

func update_preset(idx=0):
	cur_preset = preset_list[idx]
	if idx == preset_list.size() - 1:
		get_node("new_preset_dialog").popup_centered()
	get_node("pick_type").select(cur_preset["type"])
	update_skill_panel()

func update_skill_panel():
	var button_parent = get_node("picked_skill/scroll/skill_queue")
	for prev_button in button_parent.get_children():
		prev_button.queue_free()
	var skill_tscn = preload("res://ui/skill_button.tscn")
	for i in range(cur_preset["skills"].size()):
		var button = skill_tscn.instance()
		button.skill_type = cur_preset["skills"][i]
		button.queue_idx = i
		button_parent.add_child(button)

func remove_skill(queue_idx):
	cur_preset["skills"].remove(queue_idx)
	update_skill_panel()

func add_skill_to_queue(queue, skill):
	if queue.size() >= constants.SKILL_QUEUE_LEN:
		return
	queue.append(skill)

func _on_add_skill_pressed():
	cur_preset["skills"].append(get_node("pick_skill_panel/pick_skill").get_selected_ID())
	update_skill_panel()

func _on_pick_type_item_selected( ID ):
	cur_preset["type"] = ID

func _on_pick_preset_item_selected( ID ):
	update_preset(ID)

func _on_ok_pressed():
	var text = get_node("new_preset_dialog/preset_name").get_text()
	if text.empty():
		return
	cur_preset["key"] = text
	get_node("pick_preset").set_text(text)
	get_node("new_preset_dialog").hide()

func _on_save_pressed():
	var key = cur_preset["key"]
	cur_preset.erase(key)
	variants.update_preset_knight(key, cur_preset)
	build_preset_pick_button()
	get_parent().build_player_buttons()

