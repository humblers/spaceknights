extends Control

var preset_list
var cur_preset
var cur_deck_index = -1

func _ready():	
	build_deck_buttons()
	build_skill_buttons()
	build_AMMO_buttons()
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

func build_deck_buttons():
	var deck_button = get_node("Background/Deck_grid")
	preset_list = []
	var clone = variants.clone(variants.preset_knights)
	for key in clone:
		var preset = clone[key]
		preset["key"] = key
		preset_list.append(preset)
	
	if preset_list.size() > 0:
		for i in range(preset_list.size()):
			var deck = deck_button.get_node("Button1").duplicate()
			#deck.name = preset_list[i]["key"]
			deck.name = String(i+1)
			deck.index = i
			deck_button.add_child(deck)
		cur_deck_index = 0
		
func change_knight(index):
	if index < 0:
		make_new_deck()
		return
	cur_deck_index = index
	build_skill_buttons()

func make_new_deck():
	var skill_button = get_node("Background/Skill_grid")
	#cur_preset = preset_list[cur_knight_index]
	
	for i in range(8):
		skill_button.get_node("Button%d" % (i+1)).skill_type = -1
		skill_button.get_node("Button%d" % (i+1)).queue_idx = i
		skill_button.get_node("Button%d" % (i+1)).update_ui()

func build_skill_buttons():
	var skill_button = get_node("Background/Skill_grid")
	cur_preset = preset_list[cur_deck_index]
	get_node("Background/Deck_name/Label").set_text(cur_preset["key"])
	get_node("Background/Knight_type").set_text(constants.KNIGHTS[cur_preset["type"]]["type"])
	
	for i in range(8):
		if cur_preset["skills"].size() > i:
			pass
		else:
			cur_preset["skills"].append(int(0))
		skill_button.get_node("Button%d" % (i+1)).skill_type = int(cur_preset["skills"][i])
		skill_button.get_node("Button%d" % (i+1)).queue_idx = i
		skill_button.get_node("Button%d" % (i+1)).update_ui()
		
func build_AMMO_buttons():
	var AMMO_button = get_node("Background/ScrollContainer/AMMO_grid")
	
	for i in range(constants.SKILLS.size()):
		if i == 0:
			var AMMO = AMMO_button.get_node("Button1")
			AMMO.skill_type = i
			AMMO.queue_idx = i
			AMMO.update_ui()
		else:
			var AMMO = AMMO_button.get_node("Button1").duplicate()
			AMMO.skill_type = i
			AMMO.queue_idx = i
			AMMO_button.add_child(AMMO)

func change_skill(skill_type, queue_idx):
	var picked_skill = get_node("/root/main_screen/Background/Change_BG/Button")
	var skill_button = get_node("Background/Skill_grid")
	cur_preset["skills"][queue_idx] = int(picked_skill.skill_type)
	skill_button.get_node("Button%d" % (queue_idx+1)).skill_type = cur_preset["skills"][queue_idx]
	
	save_deck()

func save_deck():
	var key = cur_preset["key"]
	variants.update_preset_knight(key, cur_preset)
	
func update_preset(idx=0):
	cur_preset = preset_list[idx]
	if idx == preset_list.size() - 1:
		get_node("new_preset_dialog").popup_centered()
	get_node("pick_type").select(cur_preset["type"])
	update_skill_panel()
	
	
	