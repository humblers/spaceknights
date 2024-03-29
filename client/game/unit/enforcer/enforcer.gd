extends "res://game/script/unit.gd"

var player
var targetId = 0
var attack = 0
var attack_counter = 0

func Init(id, level, posX, posY, game, player):
	New(id, "enforcer", player.Team(), level, posX, posY, game)
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
	if attack == 0:
		if attack_counter % 2 == 0:
			$AnimationPlayer.play("attack_1")
		else:
			$AnimationPlayer.play("attack_2")
		attack_counter += 1
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			for id in game.UnitIds():
				var u = game.FindUnit(id)
				if not canAttack(u):
					continue
				var x = scalar.Sub(PositionX(), u.PositionX())
				var y = scalar.Sub(PositionY(), u.PositionY())
				var d = vector.LengthSquared(x, y)
				var r = scalar.Add(u.Radius(), attackRadius())
				if d < scalar.Mul(r, r):
					u.TakeDamage(attackDamage(), damageType(), self)
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0

func canAttack(unit):
	if Team() == unit.Team():
		return false
	if not targetTypes().has(unit.Type()):
		return false
	return true

func attackRadius():
	var r = data.units[name_]["attackradius"]
	return game.World().FromPixel(r)
	
