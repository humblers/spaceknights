extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0
var charge = 0
var shield
var player
var attack_counter = 0

func Init(id, level, posX, posY, game, player):
	New(id, "champion", player.Team(), level, posX, posY, game)
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
				splashAttack(t, chargedAttackDamage(), chargedAttackDamageType())
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
			if attack_counter % 2 == 0:
				$AnimationPlayer.play("attack1")
			else:
				$AnimationPlayer.play("attack2")
			attack_counter += 1
		var t = target()
		if t != null:
			look_at_pos(t.PositionX(), t.PositionY())
		if attack == preAttackDelay():
			if t != null and withinRange(t):
				splashAttack(t, attackDamage(), damageType())
			else:
				attack = 0
				return
		attack += 1
		if attack > attackInterval():
			attack = 0

func splashAttack(target, damage, damageType):
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		var x = scalar.Sub(target.PositionX(), u.PositionX())
		var y = scalar.Sub(target.PositionY(), u.PositionY())
		var d = vector.LengthSquared(x, y)
		var r = scalar.Add(u.Radius(), damageRadius())
		if d < scalar.Mul(r, r):
			u.TakeDamage(damage, damageType, self)
	
func chargeDelay():
	return data.units[name_]["chargedelay"]

func speed():
	var s
	if charged():
		s = data.units[name_]["chargedmovespeed"]
	else:
		s = data.units[name_]["speed"]
	
	if slowUntil >= game.Step():
		s = s * data.SlowPercent / 100
	return game.World().FromPixel(s)

func chargedAttackDamageType():
	return data.units[name_]["chargedattackdamagetype"]

func chargedAttackDamage():
	var v = data.units[name_]["chargedattackdamage"]
	var t = typeof(v)
	if t == TYPE_INT:
		return v
	if t == TYPE_ARRAY:
		return v[level]
	print("invalid charged attack damage type")

func chargedAttackInterval():
	return data.units[name_]["chargedattackinterval"]

func chargedAttackPreDelay():
	return data.units[name_]["chargedattackpredelay"]

func charged():
	return charge >= chargeDelay()

func damageRadius():
	var r = data.units[name_]["damageradius"]
	return game.World().FromPixel(r)
