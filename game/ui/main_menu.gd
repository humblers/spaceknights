extends Control

var kcp

func _process(delta):
	kcp.update()
	kcp.read()
	
func _ready():
	kcp = Kcp.new()
	kcp.dialWithOptions("127.0.0.1", 9999, 2, 2)
	kcp.write("hello")
	
	get_node("Background/blue_team").set_text("Blue Team : " + str(variants.blue_score) + " WIN")
	get_node("Background/red_team").set_text("Red Team : " + str(variants.red_score) + " WIN")
	get_node("1P").hide()
	get_node("2P").hide()
	set_process(true)
	set_process_input(true)

func _on_play_pressed():
	for i in [1, 2]:
		variants.set(
			"player%d_knight" % i,
			variants.preset_knights[get_node("%dP" % i).cur_preset["key"]]
		)
	
	print(variants.player1_knight)
	print(variants.player2_knight)
	get_tree().change_scene("res://lobby.tscn")

func _input(event):
	if event.type == InputEvent.KEY and event.is_action_pressed("ui_start_game"):
		_on_play_pressed()


func _on_HButtonArray_button_selected( button_idx ):
	if button_idx == 0:
		get_node("1P").show()
		get_node("2P").hide()
	elif button_idx == 1:
		get_node("1P").hide()
		get_node("2P").hide()
	elif button_idx == 2:
		get_node("1P").hide()
		get_node("2P").show()
