extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0

func Init(id, level, posX, posY, game, player):
	.Init(id, "blaster", player.Team(), level, posX, posY, game)
	
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

func fire():
	var b = resource.BULLET[name_].instance()
	b.Init(targetId, bulletLifeTime(), attackDamage(), game)
	game.AddBullet(b)
	b.global_position = $Rotatable/Shotpoint.global_position

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
	var x = scalar.Sub(unit.PositionX(), PositionX())
	var y = scalar.Sub(unit.PositionY(), PositionY())
	var direction = vector.Normalized(x, y)
	var speed = speed()
	SetVelocity(
		scalar.Mul(direction[0], speed), 
		scalar.Mul(direction[1], speed))
	look_at(unit.PositionX(), unit.PositionY())
	if $AnimationPlayer.current_animation != "move" or not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("move")
	

func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack")
		setLayer("Normal")
	var t = target()
	if t != null:
		look_at(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			fire()
		else:
			attack = 0
			setLayer(initialLayer())
			return
	attack += 1
	if attack > attackInterval():
		attack = 0
		setLayer(initialLayer())