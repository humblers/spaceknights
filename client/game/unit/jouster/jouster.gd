extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0
var charge = 0

func Init(id, level, posX, posY, game, player):
	New(id, "jouster", player.Team(), level, posX, posY, game)

func Update():
	.Update()
	if freeze > 0:
		attack = 0
		targetId = 0
		charge = 0
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

func Destroy():
	.Destroy()
	$AnimationPlayer.play("destroy")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func target():
	return game.FindUnit(targetId)

func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()

func findTargetAndDoAction():
	var t = findTarget()
	setTarget(t)
	if t != null:
		if withinRange(t):
			handleAttack()
		else:
			moveTo(t)
	else:
		$AnimationPlayer.play("idle")
		charge = 0

func moveTo(unit, play_anim = false):
	.moveTo(unit, play_anim)
	charge += 1
	if charge == 1:
		$AnimationPlayer.play("move")
	if charge == chargeDelay():
		$AnimationPlayer.play("charge")

func handleAttack():
	if charged():
		if attack == 0:
			$AnimationPlayer.play("charged_attack")
		var t = target()
		if t != null:
			look_at_pos(t.PositionX(), t.PositionY())
		if attack == chargedAttackPreDelay():
			if t != null and withinRange(t):
				t.TakeDamage(chargedAttackDamage(), self)
			else:
				attack = 0
				charge = 0
				return
		attack += 1
		if attack > chargedAttackInterval():
			attack = 0
			charge = 0
	else:
		charge = 0			# prevent charge accumulation
		if attack == 0:
			$AnimationPlayer.play("attack")
		var t = target()
		if t != null:
			look_at_pos(t.PositionX(), t.PositionY())
		if attack == preAttackDelay():
			if t != null and withinRange(t):
				t.TakeDamage(attackDamage(), self)
			else:
				attack = 0
				return
		attack += 1
		if attack > attackInterval():
			attack = 0

func chargeDelay():
	return stat.units[name_]["chargedelay"]

func speed():
	var s
	if charged():
		s = stat.units[name_]["chargedmovespeed"]
	else:
		s = stat.units[name_]["speed"]
	
	if slowUntil >= game.Step():
		s = s * stat.SlowPercent / 100
	return game.World().FromPixel(s)

func chargedAttackDamage():
	var v = stat.units[name_]["chargedattackdamage"]
	var t = typeof(v)
	if t == TYPE_INT:
		return v
	if t == TYPE_ARRAY:
		return v[level]
	print("invalid charged attack damage type")

func chargedAttackInterval():
	return stat.units[name_]["chargedattackinterval"]

func chargedAttackPreDelay():
	return stat.units[name_]["chargedattackpredelay"]

func charged():
	return charge >= chargeDelay()
