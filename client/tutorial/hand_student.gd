extends "res://game/player/hand.gd"

var focused = false
var revealed = false

func _ready():
	event.connect("PhaseChanged", self, "phaseChanged")

func setHand(card):
	.setHand(card)
	visible = revealed
	focusHand()

func phaseChanged(phase, PHASES):
	match index:
		1:
			focused = phase == PHASES.REQUEST_ARCHERS
			revealed = phase >= PHASES.REQUEST_ARCHERS
		2:
			focused = phase == PHASES.REQUEST_BERSERKER
			revealed = phase >= PHASES.REQUEST_BERSERKER
		3:
			focused = phase == PHASES.REQUEST_GARGOYLES
			revealed = phase >= PHASES.REQUEST_GARGOYLES
		4:
			focused = phase == PHASES.REQUEST_FIREBALL
			revealed = phase >= PHASES.REQUEST_FIREBALL
	visible = revealed
	focusHand()

func handle_input(ev):
	.handle_input(ev)
	focusHand()

func focusHand():
	if not focused:
		return
	if not pressed:
		var grect = self.get_global_rect()
		var center_global_pos = grect.position + grect.size / 2
		event.emit_signal("FocusAt", center_global_pos)
		return
	event.emit_signal("FocusOff")
	if $Cursor.visible:
		event.emit_signal("TransmissionOff")