extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0

func Init(id, level, posX, posY, game, player):
	New(id, "micromissile", player.Team(), level, posX, posY, game)
	
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
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		var x = scalar.Sub(PositionX(), u.PositionX())
		var y = scalar.Sub(PositionY(), u.PositionY())
		var d = vector.LengthSquared(x, y)
		var r = scalar.Add(scalar.Add(Radius(), u.Radius()), destroyRadius())
		if d < scalar.Mul(r, r):
			u.TakeDamage(destroyDamage(), self)
	hp = 0
	

func destroyDamage():
	return data.units[name_]["destroydamage"][level]

func destroyRadius():
	var r = data.units[name_]["destroyradius"]
	return game.World().FromPixel(r)
