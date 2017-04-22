extends Node2D
var knight_type = 0
var knight_thumb

func _ready():
	pass

func update_ui():
	if get_node("Viewport").has_node("knight_thumb"):
		get_node("Viewport/knight_thumb").queue_free()
		get_node("Viewport").remove_child(get_node("Viewport/knight_thumb"))
	
	if knight_type == 0:
		knight_thumb = preload("res://ui/knight_thumb01_3d.tscn").instance()
	elif knight_type == 1:
		knight_thumb = preload("res://ui/knight_thumb03_3d.tscn").instance()
	elif knight_type == 2:
		knight_thumb = preload("res://ui/knight_thumb04_3d.tscn").instance()
	elif knight_type == 3:
		knight_thumb = preload("res://ui/knight_thumb07_3d.tscn").instance()
	elif knight_type == 4:
		knight_thumb = preload("res://ui/knight_thumb05_3d.tscn").instance()
	"""
	elif knight_type == 5:
		knight_thumb = preload("res://ui/knight_thumb06_3d.tscn").instance()
	elif knight_type == 6:
		knight_thumb = preload("res://ui/knight_thumb07_3d.tscn").instance()
	elif knight_type == 7:
		knight_thumb = preload("res://ui/knight_thumb08_3d.tscn").instance()
	elif knight_type == 8:
		knight_thumb = preload("res://ui/knight_thumb09_3d.tscn").instance()
	"""
	knight_thumb.set_name("knight_thumb")
	get_node("Viewport").add_child(knight_thumb)
	