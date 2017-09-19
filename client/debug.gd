extends Node

var show_radius = false
var show_sight = false
var show_range = false

signal toggled

func _ready():
	input.connect("key_pressed", self, "toggle")

func toggle(key):
	if key == KEY_F1:
		show_radius = not show_radius
		emit_signal("toggled")
	elif key == KEY_F2:
		show_sight = not show_sight
		emit_signal("toggled")
	elif key == KEY_F3:
		show_range = not show_range
		emit_signal("toggled")
