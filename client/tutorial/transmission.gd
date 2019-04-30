extends Node2D

func _ready():
	event.connect("PhaseChanged", self, "phaseChanged")
	event.connect("TransmissionOff", self, "set_visible", [false])

func phaseChanged(phase, PHASES):
	match phase:
		PHASES.REQUEST_ARCHERS:
			$AnimationPlayer.play("request_archers")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
		PHASES.REQUEST_BERSERKER:
			$AnimationPlayer.play("request_berserker")
			visible = true
		PHASES.REMIND_ANTI_BARRIER:
			$AnimationPlayer.play("remind_anti_barrier")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")
		PHASES.REQUEST_GARGOYLES:
			$AnimationPlayer.play("request_gargoyles")
			visible = true
		PHASES.EXPLAIN_ENERGY_BOOST:
			$AnimationPlayer.play("explain_energy_boost")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
		PHASES.REMIND_POSITION_STRATEGY:
			$AnimationPlayer.play("remind_position_strategy")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false
			event.emit_signal("TransmissionTerminated")
		PHASES.REQUEST_FIREBALL:
			$AnimationPlayer.play("request_fireball")
			visible = true
		PHASES.TO_THE_VICTORY:
			$AnimationPlayer.play("to_the_victory")
			visible = true
			yield($AnimationPlayer, "animation_finished")
			visible = false