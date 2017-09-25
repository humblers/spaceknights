extends Node

var pressed = false

signal key_pressed(k)
signal mouse_pressed(b)
signal mouse_dragged(x)

func _ready():
	set_process_unhandled_input(true)

func _unhandled_input(event):
	# UI intercepted input not seen on here
	if event.type == InputEvent.MOUSE_BUTTON:
		pressed = event.pressed
		emit_signal("mouse_pressed", pressed)
	
	if pressed and event.type == InputEvent.MOUSE_MOTION:
		emit_signal("mouse_dragged", event.relative_pos.x)
	
	if event.type == InputEvent.KEY and event.pressed:
		emit_signal("key_pressed", event.scancode)