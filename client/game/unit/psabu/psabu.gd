extends "res://game/script/unit.gd"

var player
var targetId = 0
var attack = 0
var shield
var punchPosX
var punchPosY

func Init(id, level, posX, posY, game, player):
	.Init(id, "psabu", player.Team(), level, posX, posY, game)
	shield = initialShield()
	self.player = player
	$Hp/Shield.max_value = shield
	$Hp/Shield.value = shield

func TakeDamage(amount, attackType):
	if attackType != "Melee":
		shield -= amount
		if shield < 0:
			hp += shield
			shield = 0
		$Energyshield/AnimationPlayer.play("energyshield")
	else:
		hp -= amount
		if attackType != "Self":
			damages[game.step] = 0
	$Hp/Shield.value = shield
	node_hp.value = hp
	node_hp.visible = true
	$Hp/Shield.visible = true

func Update():
	SetVelocity(0, 0)
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
	shield += stat.ShieldRegenPerStep
	if shield > initialShield():
		shield = initialShield()
	$Hp/Shield.value = shield

func Destroy():
	.Destroy()
	$AnimationPlayer.play("explosion")
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

func moveTo(unit):
	var corner = game.Map().FindNextCornerInPath(
		PositionX(), PositionY(),
		unit.PositionX(), unit.PositionY(),
		Radius())
	var x = scalar.Sub(corner[0], PositionX())
	var y = scalar.Sub(corner[1], PositionY())
	var direction = vector.Normalized(x, y)
	var speed = speed()
	SetVelocity(
		scalar.Mul(direction[0], speed),
		scalar.Mul(direction[1], speed))
	look_at_pos(corner[0], corner[1])
	if $AnimationPlayer.current_animation != "move" or not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("move")

func handleAttack():
	var t = target()
	if attack == 0:
		$AnimationPlayer.play("attack")
		$Sound/sound_fire.play()
		look_at_pos(t.PositionX(), t.PositionY())
		var r = scalar.Add(Radius(), attackRange())
		var dx = scalar.Sub(t.PositionX(), PositionX())
		var dy = scalar.Sub(t.PositionY(), PositionY())
		var norm = vector.Normalized(dx, dy)
		dx = scalar.Mul(norm[0], r)
		dy = scalar.Mul(norm[1], r)
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
				u.TakeDamage(attackDamage(), "Melee")
	attack += 1
	if attack > attackInterval():
		attack = 0

func absorb():
	var radius = absorbRadius()
	var force = game.World().FromPixel(stat.units[name_]["absorbforce"])
	var damage = stat.units[name_]["absorbdamage"]
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team() or u.Layer() != "Normal":
			continue
		var x = scalar.Sub(punchPosX, u.PositionX())
		var y = scalar.Sub(punchPosY, u.PositionY())
		var d = vector.LengthSquared(x, y)
		var r = scalar.Add(u.Radius(), radius)
		if d <= scalar.Mul(r, r):
			var n = vector.Normalized(x, y)
			var fx = scalar.Mul(n[0], force)
			var fy = scalar.Mul(n[1], force)
			u.AddForce(fx, fy)
			u.TakeDamage(damage, "Skill")
			

func absorbRadius():
	return game.World().FromPixel(stat.units[name_]["absorbradius"])

func attackRadius():
	var r = stat.units[name_]["attackradius"]
	var divider = 1
	var ratios = player.StatRatios("arearatio")
	for i in range(len(ratios)):
		r *= ratios[i]
		divider *= 100
	return game.World().FromPixel(r / divider)
