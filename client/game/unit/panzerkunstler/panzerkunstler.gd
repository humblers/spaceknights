extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0
var attackCount = 0
var punchPosX
var punchPosY

func Init(id, level, posX, posY, game, player):
	.Init(id, "panzerkunstler", player.Team(), level, posX, posY, game)

func Update():
	SetVelocity(0, 0)
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
	else:
		$AnimationPlayer.play("idle")

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
	look_at(corner[0], corner[1])
	if $AnimationPlayer.current_animation != "move" or not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("move")

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
			$AnimationPlayer.play("attack")
			look_at(t.PositionX(), t.PositionY())
		if attack >= powerAttackPreDelay():
			for id in game.UnitIds():
				var u = game.FindUnit(id)
				if u.Team() == Team() or u.Layer() != "Normal":
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
					u.TakeDamage(powerAttackDamage(), "Melee")
		attack += 1
		if attack > powerAttackInterval():
			attack = 0
			attackCount += 1
	else:	
		if attack == 0:
			$AnimationPlayer.play("attack-2")
		var t = target()
		if t != null:
			look_at(t.PositionX(), t.PositionY())
		if attack == preAttackDelay():
			if t != null and withinRange(t):
				t.TakeDamage(attackDamage(), "Melee")
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
	return game.World().FromPixel(stat.units[name_]["powerattackradius"])

func powerAttackForce():
	return game.World().FromPixel(stat.units[name_]["powerattackforce"])
