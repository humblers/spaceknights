extends Control

var decks
var cur_deck_key
var cur_deck_info

var preset_list
var cur_deck_index = -1

func _ready():	
	get_node("Background/Knight_collection").hide()
#	build_AMMO_buttons()
#	build_knight_buttons()
	set_process_input(true)

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

func show_deck_menu():
	show()
	refresh_deck_buttons()

func refresh_deck_buttons(clone_from_variants = true):
	if clone_from_variants:
		decks = variants.clone(variants.preset_knights)
	
	var deck_button = get_node("Background/Deck_grid")
	var ori_button = deck_button.get_node("Button")
	for child in deck_button.get_children():
		if child != ori_button:
			child.queue_free()

	for key in decks:
		if cur_deck_key == null:
			cur_deck_key = key
		var deck = deck_button.get_node("Button").duplicate()
		deck.set_name("deck_button_%s" % key)
		deck.is_creator = false
		deck.name = key
		deck_button.add_child(deck)

	if cur_deck_key == null:
		make_new_deck()
		return
	build_skill_buttons()

func select_knight(key):
	cur_deck_key = key
	build_skill_buttons()

func make_new_deck():
	var new_key = "new"
	for key in decks:
		if key == new_key:
			return

	var skill_button = get_node("Background/Skill_grid")
	cur_deck_key = new_key
	cur_deck_info = {
		"type" : -1,
		"skills" : []
	}
	decks[new_key] = cur_deck_info
	
	get_node("Background/Deck_name/new_preset_dialog").popup_centered()
	save_cur_deck()
	refresh_deck_buttons(false)

func build_skill_buttons():
	var skill_button = get_node("Background/Skill_grid")
	cur_deck_info = decks[cur_deck_key]
	get_node("Background/Deck_name/Label").set_text(cur_deck_key)
	get_node("Background/Knight_type").knight_type = cur_deck_info["type"]
	get_node("Background/Knight_type").update_ui()
	
	for i in range(8):
		if cur_deck_info["skills"].size() > i:
			pass
		else:
			cur_deck_info["skills"].append(int(-1))
		skill_button.get_node("Button%d" % (i+1)).skill_type = int(cur_deck_info["skills"][i])
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
	cur_deck_info["skills"][queue_idx] = int(picked_skill.skill_type)
	skill_button.get_node("Button%d" % (queue_idx+1)).skill_type = cur_deck_info["skills"][queue_idx]
	save_cur_deck()

func change_knight(knight_type):
	cur_deck_info["type"] = knight_type
	get_node("Background/Knight_type").knight_type = knight_type
	get_node("Background/Knight_type").update_ui()
	save_cur_deck()
	
func change_deck_name():
	var text = get_node("Background/Deck_name/new_preset_dialog/preset_name").get_text()
	if text.empty():
		return
	var deck = decks[cur_deck_key]
	decks.erase(cur_deck_key)
	variants.preset_knights.erase(cur_deck_key)
	cur_deck_key = text
	decks[cur_deck_key] = deck
	get_node("Background/Deck_name/Label").set_text(cur_deck_key)
	get_node("Background/Deck_name/new_preset_dialog").hide()
	save_cur_deck()
	refresh_deck_buttons()

func delete_deck():
	variants.preset_knights.erase(cur_deck_key)
	cur_deck_key = null
	refresh_deck_buttons()
	save_cur_deck()

func save_cur_deck():
	variants.update_preset_knight(cur_deck_key, cur_deck_info)

func update_preset(idx=0):
	cur_deck_info = preset_list[idx]
	if idx == preset_list.size() - 1:
		get_node("new_preset_dialog").popup()
	get_node("pick_type").select(cur_deck_info["type"])
	update_skill_panel()

func _on_Deck_name_Button_pressed():
	get_node("Background/Deck_name/new_preset_dialog").popup_centered()

func _on_Deck_name_ok_pressed():
	change_deck_name()

func _on_Del_pressed():
	delete_deck()


