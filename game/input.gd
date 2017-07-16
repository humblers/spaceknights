extends Node

var pressed = false

signal mouse_pressed(b)
signal mouse_dragged(x)

func _ready():
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		pressed = event.pressed
		emit_signal("mouse_pressed", pressed)
	
	if pressed and event.type == InputEvent.MOUSE_MOTION:
		emit_signal("mouse_dragged", event.relative_pos.x)