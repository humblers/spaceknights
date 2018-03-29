extends Node

var pressed = false

signal key_pressed(k)
signal mouse_pressed(pos)
signal mouse_dragged(x)

func _ready():
	set_process_unhandled_input(true)

func _unhandled_input(event):
	# UI intercepted input not seen on here
	if event is InputEventMouseButton and event.pressed:
		emit_signal("mouse_pressed", event.pos)
	
	if pressed and event is InputEventMouseMotion:
		emit_signal("mouse_dragged", event.relative_pos.x)
	
	if event is InputEventKey and event.pressed:
		emit_signal("key_pressed", event.scancode)