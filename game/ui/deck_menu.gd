extends Control

var presets
var cur_deck

var cur_preset

var preset_list
var cur_deck_index = -1

func _ready():	
	presets = variants.clone(variants.preset_knights)
	get_node("Background/Knight_collection").hide()
	cur_deck_index = 0
	refresh_deck_buttons()
#	build_skill_buttons()
#	build_AMMO_buttons()
#	build_knight_buttons()
#	set_process_input(true)

func _on_play_pressed():
	for i in [1, 2]:
		variants.set(
			"player%d_knight" % i,
			variants.preset_knights[get_node("pick_knight/player%d" % i).get_text()]
		)
	get_tree().change_scene("res://main.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()

func refresh_deck_buttons():
	var deck_button = get_node("Background/Deck_grid")
	var ori_button = deck_button.get_node("Button")
	for child in deck_button.get_children():
		if child != ori_button:
			child.queue_free()
#	preset_list = []
#	var clone = variants.clone(variants.preset_knights)
#	for key in clone:
#		var preset = clone[key]
#		preset["key"] = key
#		preset_list.append(preset)
	for key in presets:
		var deck = deck_button.get_node("Button").duplicate()
		deck.set_name("deck_button_%s" % key)
		deck.is_creator = false
		deck.name = key
		deck_button.add_child(deck)

func select_knight(key):
	cur_deck = key
	build_skill_buttons()

func make_new_deck():
	var new_key = "new"
	for key in presets:
		if key == new_key:
			return

	var skill_button = get_node("Background/Skill_grid")
	cur_deck = new_key
	cur_preset = {
		"type" : -1,
		"skills" : []
	}
	presets[new_key] = cur_preset
	
	get_node("Background/Deck_name/new_preset_dialog").popup_centered()
	refresh_deck_buttons()
	build_skill_buttons()
	save_cur_deck()

func build_skill_buttons():
	var skill_button = get_node("Background/Skill_grid")
	print("what the", cur_deck, presets)
	cur_preset = presets[cur_deck]
	get_node("Background/Deck_name/Label").set_text(cur_deck)
	get_node("Background/Knight_type").knight_type = cur_preset["type"]
	get_node("Background/Knight_type").update_ui()
	
	for i in range(8):
		if cur_preset["skills"].size() > i:
			pass
		else:
			cur_preset["skills"].append(int(-1))
		skill_button.get_node("Button%d" % (i+1)).skill_type = int(cur_preset["skills"][i])
		skill_button.get_node("Button%d" % (i+1)).queue_idx = i
		skill_button.get_node("Button%d" % (i+1)).update_ui()
		
func build_AMMO_buttons():
	var AMMO_button = get_node("Background/AMMO_collection/ScrollContainer/AMMO_grid")
	
	for i in range(constants.SKILLS.size()):
		if i == 0:
			var AMMO = AMMO_button.get_node("Button1")
			AMMO.skill_type = i
			AMMO.update_ui()
		else:
			var AMMO = AMMO_button.get_node("Button1").duplicate()
			AMMO.skill_type = i
			AMMO_button.add_child(AMMO)

func build_knight_buttons():
	var knight_button = get_node("Background/Knight_collection/ScrollContainer/Knight_grid")
	
	for i in range(constants.KNIGHTS.size()):
		if i == 0:
			var knight = knight_button.get_node("Button1")
			knight.knight_type = i
			knight.update_ui()
		else:
			var knight = knight_button.get_node("Button1").duplicate()
			knight.knight_type = i
			knight_button.add_child(knight)

func change_skill(skill_type, queue_idx):
	var picked_skill = get_node("Background/Change_skill/Button")
	var skill_button = get_node("Background/Skill_grid")
	cur_preset["skills"][queue_idx] = int(picked_skill.skill_type)
	skill_button.get_node("Button%d" % (queue_idx+1)).skill_type = cur_preset["skills"][queue_idx]
	save_cur_deck()

func change_knight(knight_type):
	cur_preset["type"] = knight_type
	get_node("Background/Knight_type").knight_type = knight_type
	get_node("Background/Knight_type").update_ui()
	save_cur_deck()
	
func change_deck_name():
	var text = get_node("Background/Deck_name/new_preset_dialog/preset_name").get_text()
	if text.empty():
		return
	var preset = presets[cur_deck]
	presets.erase(cur_deck)
	variants.preset_knights.erase(cur_deck)
	cur_deck = text
	presets[cur_deck] = preset
	get_node("Background/Deck_name/Label").set_text(cur_deck)
	get_node("Background/Deck_name/new_preset_dialog").hide()
	save_cur_deck()
	refresh_deck_buttons()

func delete_deck():
	preset_list.erase(cur_preset)
	variants.preset_knights.erase(cur_preset["key"])	
	refresh_deck_buttons()
	cur_deck_index = cur_deck_index-1
	if cur_deck_index < 0:
		cur_deck_index = 0
	build_skill_buttons()
	save_cur_deck()

func save_cur_deck():
	var key = cur_deck
	variants.update_preset_knight(key, cur_preset)
	
func update_preset(idx=0):
	cur_preset = preset_list[idx]
	if idx == preset_list.size() - 1:
		get_node("new_preset_dialog").popup()
	get_node("pick_type").select(cur_preset["type"])
	update_skill_panel()
	
func _on_Deck_name_Button_pressed():
	get_node("Background/Deck_name/new_preset_dialog").popup_centered()

func _on_Deck_name_ok_pressed():
	change_deck_name()
	
func _on_Del_pressed():
	delete_deck()


