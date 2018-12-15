extends Node2D

func Show(isSpell):
	visible = true
	$Unit.visible = not isSpell
	$Spell.visible = isSpell

func Hide():
	visible = false
	
func Expand(color, side):
	if side == "Center":
		return
	if color == "Blue":
		$Unit.get_node("%s%s" % [color, side]).visible = true
		$Unit/Deco.get_node("Knight%s" % side).visible = false
	else:
		$Unit.get_node("Extend%s" % side).visible = true
		$Unit.get_node("Red%s" % side).visible = false
