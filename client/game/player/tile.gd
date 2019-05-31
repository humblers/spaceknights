extends Node2D

var focus_index = -1

func _ready():
	event.connect("BlueKnightDead", self, "expand", ["Blue"])
	event.connect("RedKnightDead", self, "expand", ["Red"])

func Show(isSpell, index):
	focus_index = index
	visible = true
	$Grid.visible = true
	$Unit.visible = not isSpell
	$Spell.visible = isSpell

func Hide(type = null, index = -1):
	if focus_index != index:
		return
	$Grid.visible = false
	if !type:
		visible = false
	else:
		match type:
			"Unit":
				$Unit.visible = false
				return
			"Spell":
				$Spell.visible = false
				return
	
func expand(side, color):
	if side == "Center":
		return
	if color == "Blue":
		$Unit/Blue.get_node("%s%s" % [color, side]).visible = true
		$Spell/Deco.get_node("Knight%s" % side).visible = false
	else:
		$Unit/Blue.get_node("Extend%s" % side).visible = true
		$Unit/Red.get_node("Red%s" % side).visible = false
