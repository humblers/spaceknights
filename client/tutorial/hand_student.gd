extends "res://game/player/hand.gd"

var marked = false
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
			marked = phase == PHASES.REQUEST_ARCHERS
			revealed = phase >= PHASES.REQUEST_ARCHERS
		2:
			marked = phase == PHASES.REQUEST_BERSERKER
			revealed = phase >= PHASES.REQUEST_BERSERKER
		3:
			marked = phase == PHASES.REQUEST_GARGOYLES
			revealed = phase >= PHASES.REQUEST_GARGOYLES
		4:
			marked = phase == PHASES.REQUEST_FIREBALL
			revealed = phase >= PHASES.REQUEST_FIREBALL
	visible = revealed
	focusHand()

func handle_input(ev, side = null):
	.handle_input(ev, side)
	focusHand()

func focusHand():
	if not marked:
		return
	if not pressed:
		var grect = self.get_global_rect()
		var center_global_pos = grect.position + grect.size / 2
		event.emit_signal("MarkAt", center_global_pos)
		return
	event.emit_signal("MarkOff")
	if $Cursor.visible:
		event.emit_signal("TransmissionOff")