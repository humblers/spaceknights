extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0
var player

func Init(id, level, posX, posY, game, player):
	New(id, "azero", player.Team(), level, posX, posY, game)
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

func fire():
	var b = $ResourcePreloader.get_resource("ice_orb").instance()
	b.Init(targetId, bulletLifeTime(), attackDamage(), damageType(), game)
	b.MakeSplash(damageRadius())
	b.MakeFrozen(slowDuration())
	game.AddBullet(b)

	b.global_position = $Rotatable/Body/Shotpoint.global_position

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
		$AnimationPlayer.play("attack")
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			fire()
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0

func damageRadius():
	var r = data.units[name_]["damageradius"]
	return game.World().FromPixel(r)
	
func slowDuration():
	return data.units[name_]["slowduration"]
