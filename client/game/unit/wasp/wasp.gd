extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0
var shield = 0

func Init(id, level, posX, posY, game, player):
	New(id, "wasp", player.Team(), level, posX, posY, game)
	shield = initialShield()
	$Hp/HBoxContainer/VBoxContainer/Shield.max_value = shield
	$Hp/HBoxContainer/VBoxContainer/Shield.value = shield

func TakeDamage(amount, damageType, attacker):
	var alreadyDead = IsDead()
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
	if not alreadyDead and IsDead():
		game.camera.Shake(0.5, 60, 12)
		for id in game.UnitIds():
			var u = game.FindUnit(id)
			if u.Team() == Team():
				continue
			var x = scalar.Sub(PositionX(), u.PositionX())
			var y = scalar.Sub(PositionY(), u.PositionY())
			var d = vector.LengthSquared(x, y)
			var r = scalar.Add(u.Radius(), destroyRadius())
			if d < scalar.Mul(r, r):
				u.TakeDamage(destroyDamage(), destroyDamageType(), self)
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
	if targetId == 0:
		$AnimationPlayer.play("idle")
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

func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack")
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			t.TakeDamage(attackDamage(), damageType(), self)
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0

func destroyDamageType():
	return data.units[name_]["destroydamagetype"]

func destroyDamage():
	return data.units[name_]["destroydamage"][level]

func destroyRadius():
	var r = data.units[name_]["destroyradius"]
	return game.World().FromPixel(r)
