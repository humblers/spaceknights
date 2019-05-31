extends Node2D

func _ready():
	event.connect("BlueKnightDead", self, "expand", ["Blue"])
	event.connect("RedKnightDead", self, "expand", ["Red"])

func Show(isSpell):
	visible = true
	$Grid.visible = true
	$Unit.visible = not isSpell
	$Spell.visible = isSpell

func Hide(type = null):
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
