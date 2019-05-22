extends "res://game/script/unit.gd"

var player
var targetId = 0
var attack = 0
var attackCount = 0
var shield
var punchPosX
var punchPosY

func Init(id, level, posX, posY, game, player):
	New(id, "panzerkunstler", player.Team(), level, posX, posY, game)
	self.player = player
	shield = initialShield()
	$Hp/HBoxContainer/VBoxContainer/Shield.max_value = shield
	$Hp/HBoxContainer/VBoxContainer/Shield.value = shield

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
	var node_hp = get_node("Hp/HBoxContainer/VBoxContainer/%s" % color)
	node_hp.value = hp
	node_hp.visible = true
	$Hp/HBoxContainer/VBoxContainer/Shield.value = shield
	$Hp/HBoxContainer/VBoxContainer/Shield.visible = true
	$Hp/HBoxContainer/Control.visible = true

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
	shield += data.ShieldRegenPerStep
	if shield > initialShield():
		shield = initialShield()
	$Hp/HBoxContainer/VBoxContainer/Shield.value = shield

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

func handleAttack():
	if attack == 0:
		var t = target()
		var dx = scalar.Sub(t.PositionX(), PositionX())
		var dy = scalar.Sub(t.PositionY(), PositionY())
		var norm = vector.Normalized(dx, dy)
		dx = scalar.Mul(norm[0], attackRange())
		dy = scalar.Mul(norm[1], attackRange())
		punchPosX = scalar.Add(PositionX(), dx)
		punchPosY = scalar.Add(PositionY(), dy)
		if attackCount % 2 == 0:
			$AnimationPlayer.play("attack_1")
		else:
			$AnimationPlayer.play("attack_2")
		look_at_pos(t.PositionX(), t.PositionY())
	if attack >= preAttackDelay():
		for id in game.UnitIds():
			var u = game.FindUnit(id)
			if u.Team() == Team() or u.Layer() != data.Normal:
				continue
			var x = scalar.Sub(u.PositionX(), punchPosX)
			var y = scalar.Sub(u.PositionY(), punchPosY)
			var d = vector.LengthSquared(x, y)
			var r = scalar.Add(u.Radius(), attackRadius())
			if d < scalar.Mul(r, r):
				var n = vector.Normalized(x, y)
				var fx = scalar.Mul(n[0], attackForce())
				var fy = scalar.Mul(n[1], attackForce())
				u.AddForce(fx, fy)
			r = scalar.Add(u.Radius(), attackDamageRadius())
			if d < scalar.Mul(r, r) and attack == preAttackDelay():
				u.TakeDamage(attackDamage(), damageType(), self)
	if attack == preAttackDelay():
		game.camera.Shake(0.5, 60, 8)
	attack += 1
	if attack > attackInterval():
		attack = 0
		attackCount += 1

func attackDamageRadius():
	var r = data.units[name_]["attackdamageradius"]
	return game.World().FromPixel(r)

func attackRadius():
	var r = data.units[name_]["attackradius"]
	return game.World().FromPixel(r)

func attackForce():
	return game.World().FromPixel(data.units[name_]["attackforce"])
