extends Control

func Set(name):
	for icon in get_children():
		if icon.name == name:
			icon.visible = true
		else:
			icon.visible = false
			
func Open(name):
	for icon in get_children():
		if icon.name == name:
			icon.visible = true
			icon.get_node("Chest").play("chestopen")
		else:
			icon.visible = false
