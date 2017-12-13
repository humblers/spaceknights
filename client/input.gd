extends Node

var pressed = false

signal key_pressed(k)
signal mouse_pressed(pos)
signal mouse_dragged(rel)
signal second_touched(ev)

func _ready():
	set_process_unhandled_input(true)

func _unhandled_input(event):
	# UI intercepted input not seen on here
	if event.type == InputEvent.MOUSE_BUTTON:
		pressed = event.pressed
		#emit_signal("mouse_pressed", event.pos)

	if event.type == InputEvent.MOUSE_MOTION and pressed:
		emit_signal("mouse_dragged", event.relative_pos)

	if event.type == InputEvent.SCREEN_TOUCH and event.index == 1:
		emit_signal("second_touched", event)

	if event.type == InputEvent.KEY and event.pressed:
		emit_signal("key_pressed", event.scancode)