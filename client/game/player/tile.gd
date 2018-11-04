extends Node2D

func ShowArea(is_unit):
	visible = true
	$Unit.visible = is_unit
	$Spell.visible = not is_unit

func Hide():
	visible = false

func OnKnightDead(team, side):
	if team == "Blue":
		$Unit.get_node("%s%s" % [team, side]).visible = true
		$Unit/Deco.get_node("Knight%s" % side).visible = false
	else:
		$Unit.get_node("Extend%s" % side).visible = true
		$Unit.get_node("Red%s" % side).visible = false
