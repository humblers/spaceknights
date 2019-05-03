extends Node2D

func _ready():
	event.connect("PhaseChanged", self, "phaseChanged")
	event.connect("TransmissionOff", self, "set_visible", [false])

func phaseChanged(phase, PHASES):
	match phase:
		PHASES.HELLO:
			$AnimationPlayer.play("01_hello")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")
		PHASES.REQUEST_ARCHERS:
			$AnimationPlayer.play("02_request_archers")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
		PHASES.COMPLIMENT_ARCHERS:
			$AnimationPlayer.play("03_compliment_archers")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
		PHASES.EXPLAIN_BERSERKER:
			$AnimationPlayer.play("04_explain_berserker")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			event.emit_signal("TransmissionTerminated")
		PHASES.REQUEST_BERSERKER:
			$AnimationPlayer.play("05_request_berserker")
			visible = true
		PHASES.REMIND_ANTI_BARRIER:
			$AnimationPlayer.play("06_remind_anti_barrier")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")
		PHASES.REQUEST_GARGOYLES:
			$AnimationPlayer.play("07_request_gargoyles")
			visible = true
		PHASES.EXPLAIN_ENERGY_BOOST:
			$AnimationPlayer.play("08_explain_energy_boost")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")
		PHASES.COMPLIMENT_BOOST:
			$AnimationPlayer.play("09_compliment_boost")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")
		PHASES.REMIND_POSITION_STRATEGY:
			$AnimationPlayer.play("10_remind_position_strategy")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
		PHASES.REQUEST_FIREBALL:
			$AnimationPlayer.play("11_request_fireball")
			visible = true
		PHASES.COMPLIMENT_FIREBALL:
			$AnimationPlayer.play("12_compliment_fireball")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")
		PHASES.TO_THE_VICTORY:
			$AnimationPlayer.play("13_to_the_victory")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
		PHASES.WIN:
			$AnimationPlayer.play("14_win")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")
		PHASES.LOSE:
			$AnimationPlayer.play("15_lose")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")