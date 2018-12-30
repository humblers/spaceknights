extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0

func Init(id, level, posX, posY, game, player):
	New(id, "heavymissile", player.Team(), level, posX, posY, game)

func TakeDamage(amount, damageType, attacker):
	var alreadyDead = IsDead()
	.TakeDamage(amount, damageType, attacker)
	if not alreadyDead and IsDead() and attack > 0 and attack <= preAttackDelay():
		suicideAttack()
		attack = preAttackDelay() + 1

func Update():
	.Update()
	if attack > 0:
		handleAttack()
	else:
		if freeze > 0:
			targetId = 0
			freeze -= 1
			return
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
	if $AnimationPlayer.current_animation != "destroy":
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

func suicideAttack():
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		var x = scalar.Sub(PositionX(), u.PositionX())
		var y = scalar.Sub(PositionY(), u.PositionY())
		var d = vector.LengthSquared(x, y)
		var r = scalar.Add(u.Radius(), attackRadius())
		if d < scalar.Mul(r, r):
			u.TakeDamage(attackDamage(), damageType(), self)
	if not IsDead():
		hp = 0

func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("destroy")
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		suicideAttack()
	attack += 1

func attackRadius():
	var r = data.units[name_]["attackradius"]
	return game.World().FromPixel(r)