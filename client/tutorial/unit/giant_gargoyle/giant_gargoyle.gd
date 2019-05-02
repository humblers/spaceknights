extends "res://game/unit/gargoyleking/gargoyleking.gd"

func Init(id, level, posX, posY, game, player):
	New(id, "giant_gargoyle", player.Team(), level, posX, posY, game)
	shield = initialShield()
	$Hp/HBoxContainer/VBoxContainer/Shield.max_value = shield
	$Hp/HBoxContainer/VBoxContainer/Shield.value = shield

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