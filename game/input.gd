extends Node

var pressed = false

signal mouse_dragged(x)

func _ready():
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		pressed = event.pressed
	
	if pressed and event.type == InputEvent.MOUSE_MOTION:
		emit_signal("mouse_dragged", event.relative_pos.x)