extends Control

var preset_list
var cur_preset

func _ready():	
	build_battledeck_buttons()
	set_process_input(true)

func _on_play_pressed():
	for i in [1, 2]:
		variants.set(
			"player%d_knight" % i,
			variants.preset_knights[get_node("pick_knight/player%d" % i).get_text()]
		)
	print(variants.player1_knight)
	print(variants.player2_knight)
	get_tree().change_scene("res://main.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()

func build_battledeck_buttons():
	var skill_button = get_node("Background/Knights_grid")
	preset_list = []
	var clone = {}
	clone.parse_json(variants.preset_knights.to_json())
	for key in clone:
		var preset = clone[key]
		preset["key"] = key
		preset_list.append(preset)
	
	
	#skill_button.clear()
	for i in range(preset_list.size()):
		#skill_button.add_item(preset_list[i]["key"], i)
		var knight = skill_button.get_node("Button1").duplicate()
		knight.text = preset_list[i]["key"]
		skill_button.add_child(knight)
		print(preset_list[i]["key"])
	#update_preset()
	
	#for i in range(constants.SKILLS.size()):
	#	skill_button.get_node("Button%d" % i)
	#	pick_button.add_item(constants.SKILLS[i]["name"], i)
		
func update_preset(idx=0):
	cur_preset = preset_list[idx]
	if idx == preset_list.size() - 1:
		get_node("new_preset_dialog").popup_centered()
	get_node("pick_type").select(cur_preset["type"])
	update_skill_panel()
	
	
	