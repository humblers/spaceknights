extends Node

# options
var show_radius = false
var show_sight = false
var show_range = false
var show_velocity = false
var size_changed = false

signal option_changed

func _ready():
	input.connect("key_pressed", self, "on_key_pressed")
	
func on_key_pressed(key):
	if key == KEY_F1:
		show_radius = not show_radius
		emit_signal("option_changed")
	elif key == KEY_F2:
		show_sight = not show_sight
		emit_signal("option_changed")
	elif key == KEY_F3:
		show_range = not show_range
		emit_signal("option_changed")
	elif key == KEY_F4:
		show_velocity = not show_velocity
		emit_signal("option_changed")
	elif key == KEY_F9:
		OS.window_size = Vector2(480, 640)
		size_changed = true
	elif key == KEY_F10:
		OS.window_size = Vector2(1080, 1920)
		size_changed = true