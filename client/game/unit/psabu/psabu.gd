extends "res://game/script/unit.gd"

var player
var targetId = 0
var attack = 0
var shield
var punchPosX
var punchPosY

func Init(id, level, posX, posY, game, player):
	New(id, "psabu", player.Team(), level, posX, posY, game)
	shield = initialShield()
	self.player = player
	$Hp/Shield.max_value = shield
	$Hp/Shield.value = shield

func TakeDamage(amount, damageType, attacker):
	if not data.DamageTypeIs(damageType, data.AntiShield):
		shield -= amount
		if shield < 0:
			hp += shield
			shield = 0
			damages[game.step] = 0
			$HitEffect.hit(damageType)
		else:
			$Energyshield.hit(attacker)
	else:
		hp -= amount
		damages[game.step] = 0
		$HitEffect.hit(damageType)
	$Hp/Shield.value = shield
	node_hp.value = hp
	node_hp.visible = true
	$Hp/Shield.visible = true

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
	shield += data.ShieldRegenPerStep
	if shield > initialShield():
		shield = initialShield()
	$Hp/Shield.value = shield

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

func handleAttack():
	var t = target()
	if attack == 0:
		$AnimationPlayer.play("attack")
		look_at_pos(t.PositionX(), t.PositionY())
		var dx = scalar.Sub(t.PositionX(), PositionX())
		var dy = scalar.Sub(t.PositionY(), PositionY())
		var norm = vector.Normalized(dx, dy)
		dx = scalar.Mul(norm[0], attackRange())
		dy = scalar.Mul(norm[1], attackRange())
		punchPosX = scalar.Add(PositionX(), dx)
		punchPosY = scalar.Add(PositionY(), dy)
	if attack < preAttackDelay():
		absorb()
	if attack == preAttackDelay():
		var radius = attackRadius()
		for id in game.UnitIds():
			var u = game.FindUnit(id)
			if u.Team() == Team():
				continue
			var x = scalar.Sub(punchPosX, u.PositionX())
			var y = scalar.Sub(punchPosY, u.PositionY())
			var d = vector.LengthSquared(x, y)
			var r = scalar.Add(u.Radius(), radius)
			if d < scalar.Mul(r, r):
				u.TakeDamage(attackDamage(), damageType(), self)
	attack += 1
	if attack > attackInterval():
		attack = 0

func absorb():
	var absorbRadius = game.World().FromPixel(data.units[name_]["absorbradius"])
	var damageRadius = game.World().FromPixel(data.units[name_]["absorbdamageradius"])
	var force = game.World().FromPixel(data.units[name_]["absorbforce"])
	var damage = data.units[name_]["absorbdamage"]
	var damageType = data.units[name_]["absorbdamagetype"]
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team() or u.Layer() != data.Normal:
			continue
		var x = scalar.Sub(punchPosX, u.PositionX())
		var y = scalar.Sub(punchPosY, u.PositionY())
		var d = vector.LengthSquared(x, y)
		var r = scalar.Add(u.Radius(), absorbRadius)
		if d < scalar.Mul(r, r):
			var n = vector.Normalized(x, y)
			var fx = scalar.Mul(n[0], force)
			var fy = scalar.Mul(n[1], force)
			u.AddForce(fx, fy)
		r = scalar.Add(u.Radius(), damageRadius)
		if d < scalar.Mul(r, r):
			u.TakeDamage(damage, damageType, self)

func attackRadius():
	var r = data.units[name_]["attackradius"]
	return game.World().FromPixel(r)
