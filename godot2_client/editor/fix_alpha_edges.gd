extends Control

onready var success = get_node("Success/List")
onready var fail = get_node("Fail/List")

func _on_Button_pressed():
	convert_png_in("res://")

func convert_png_in(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		while true:
			var file_name = dir.get_next()
			if file_name == "":
				break
			if file_name == "." or file_name == "..":
				continue
			if not path.ends_with("/"):
				path += "/"
			if dir.current_is_dir():
				convert_png_in(path + file_name)
			else:
				if not file_name.ends_with("png"):
					continue
				fix_alpha_edges(path + file_name)
			yield(get_tree(), "idle_frame")
	else:
		print("invalid path")

func fix_alpha_edges(png_path):
	var img = Image()
	if img.load(png_path) != OK:
		fail.add_text(png_path + "\n")
	img.fix_alpha_edges()
	if img.save_png(png_path) != OK:
		fail.add_text(png_path + "\n")
	success.add_text(png_path + "\n")