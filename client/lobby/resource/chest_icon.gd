extends Control

func Set(name):
	for icon in get_children():
		if icon.name == name:
			icon.visible = true
		else:
			icon.visible = false
