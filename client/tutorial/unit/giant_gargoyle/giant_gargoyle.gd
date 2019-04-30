extends "res://game/unit/gargoyle/gargoyle.gd"

func Update():
	.Update()
	if freeze > 0:
		attack = 0
		targetId = 0
		freeze -= 1
		return
	if attack > 0:
		handleAttack()
	else:
		var t = target()
		if t == null:
			findTargetAndDoAction()
		else:
			if withinRange(t):
				handleAttack()
			else:
				findTargetAndDoAction()
	if targetId == 0:
		$AnimationPlayer.play("idle")
	shield += game.GIANT_GARGOYLE_SHIELD_REGEN_PER_STEP
	if shield > initialShield():
		shield = initialShield()
	$Hp/HBoxContainer/VBoxContainer/Shield.value = shield

func initialShield():
	var v = data.units[name_]["shield"]
	return v[level] * game.GIANT_GARGOYLE_SHIELD_MULTIPLIER