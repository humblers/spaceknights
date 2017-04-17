extends Button
var name = "+"
var index = -1

func _ready():
	set_text(name)


func _on_Button1_pressed():
	get_node("/root/main_screen").change_knight(index)
