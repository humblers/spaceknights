extends "res://game/script/unit.gd"

var player
var targetId = 0
var attack = 0
var attackCount = 0
var punchPosX
var punchPosY

func Init(id, level, posX, posY, game, player):
	New(id, "panzerkunstler", player.Team(), level, posX, posY, game)
	self.player = player

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
	if canDoPowerAttack():
		if attack == 0:
			var t = target()
			var r = scalar.Add(Radius(), attackRange())
			var dx = scalar.Sub(t.PositionX(), PositionX())
			var dy = scalar.Sub(t.PositionY(), PositionY())
			var norm = vector.Normalized(dx, dy)
			dx = scalar.Mul(norm[0], r)
			dy = scalar.Mul(norm[1], r)
			punchPosX = scalar.Add(PositionX(), dx)
			punchPosY = scalar.Add(PositionY(), dy)
			$AnimationPlayer.play("attack_1")
			look_at_pos(t.PositionX(), t.PositionY())
		if attack >= powerAttackPreDelay():
			for id in game.UnitIds():
				var u = game.FindUnit(id)
				if u.Team() == Team() or u.Layer() != stat.Normal:
					continue
				var x = scalar.Sub(u.PositionX(), punchPosX)
				var y = scalar.Sub(u.PositionY(), punchPosY)
				var d = vector.LengthSquared(x, y)
				var r = scalar.Add(u.Radius(), powerAttackRadius())
				if d <= scalar.Mul(r, r):
					var n = vector.Normalized(x, y)
					var fx = scalar.Mul(n[0], powerAttackForce())
					var fy = scalar.Mul(n[1], powerAttackForce())
					u.AddForce(fx, fy)
					if attack == powerAttackPreDelay():
						u.TakeDamage(powerAttackDamage(), self)
		attack += 1
		if attack > powerAttackInterval():
			attack = 0
			attackCount += 1
	else:	
		if attack == 0:
			$AnimationPlayer.play("attack_2")
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
			attackCount += 1

func canDoPowerAttack():
	return attackCount % powerAttackFrequency() == 0

func powerAttackInterval():
	return stat.units[name_]["powerattackinterval"]

func powerAttackPreDelay():
	return stat.units[name_]["powerattackpredelay"]

func powerAttackFrequency():
	return stat.units[name_]["powerattackfrequency"]

func powerAttackDamage():
	var v = stat.units[name_]["powerattackdamage"]
	var t = typeof(v)
	if t == TYPE_INT:
		return v
	if t == TYPE_ARRAY:
		return v[level]
	print("invalid power attack damage type")

func powerAttackRadius():
	var r = stat.units[name_]["powerattackradius"]
	var divider = 1
	var ratios = player.StatRatios("arearatio")
	for i in range(len(ratios)):
		r *= ratios[i]
		divider *= 100
	return game.World().FromPixel(r / divider)

func powerAttackForce():
	return game.World().FromPixel(stat.units[name_]["powerattackforce"])
