extends "res://game/script/unit.gd"

var player
var targetId = 0
var attack = 0

func Init(id, level, posX, posY, game, player):
	New(id, "enforcer", player.Team(), level, posX, posY, game)
	self.player = player

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
	if attack == 0:
		$AnimationPlayer.play("attack")
		$Sound/sound_fire.play()
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
				var r = scalar.Add(scalar.Add(Radius(), u.Radius()), attackRadius())
				if d < scalar.Mul(r, r):
					u.TakeDamage(attackDamage(), "Melee")
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
	var r = stat.units[name_]["attackradius"]
	var divider = 1
	var ratios = player.StatRatios("arearatio")
	for i in range(len(ratios)):
		r *= ratios[i]
		divider *= 100
	return game.World().FromPixel(r / divider)
	