extends Node2D

func _ready():
	event.connect("PhaseChanged", self, "phaseChanged")
	event.connect("TransmissionOff", self, "set_visible", [false])

func phaseChanged(phase, PHASES):
	match phase:
		PHASES.REQUEST_ARCHERS:
			$AnimationPlayer.play("1_request_archers")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
		PHASES.COMPLIMENT_ARCHERS:
			$AnimationPlayer.play("11_")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
		PHASES.EXPLAIN_BERSERKER:
			$AnimationPlayer.play("2_request_berserker")
			visible = true
		PHASES.REQUEST_BERSERKER:
			$AnimationPlayer.play("22")
			visible = true
		PHASES.REMIND_ANTI_BARRIER:
			$AnimationPlayer.play("3_remind_anti_barrier")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")
		PHASES.REQUEST_GARGOYLES:
			$AnimationPlayer.play("4_request_gargoyles")
			visible = true
		PHASES.EXPLAIN_ENERGY_BOOST:
			$AnimationPlayer.play("5_explain_energy_boost")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
		PHASES.REMIND_POSITION_STRATEGY:
			$AnimationPlayer.play("6_remind_position_strategy")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")
		PHASES.REQUEST_FIREBALL:
			$AnimationPlayer.play("7_request_fireball")
			visible = true
		PHASES.TO_THE_VICTORY:
			$AnimationPlayer.play("8_to_the_victory")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false