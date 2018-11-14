extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0
var charge = 0

func Init(id, level, posX, posY, game, player):
	New(id, "jouster", player.Team(), level, posX, posY, game)

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

func moveTo(unit):
	var x
	var y
	if Layer() == "Ether":
		x = scalar.Sub(unit.PositionX(), PositionX())
		y = scalar.Sub(unit.PositionY(), PositionY())
	else:
		var corner = game.Map().FindNextCornerInPath(
			PositionX(), PositionY(),
			unit.PositionX(), unit.PositionY(),
			Radius())
		x = scalar.Sub(corner[0], PositionX())
		y = scalar.Sub(corner[1], PositionY())
	var direction = vector.Normalized(x, y)
	var speed = speed()
	if charged():
		speed = chargedMoveSpeed()
		if $Sound/WingMove.playing == false:
			$Sound/WingMove.play()
	else:
		if $Sound/Move.playing == false:
			$Sound/Move.play()
	var desired_vel_x = scalar.Mul(direction[0], speed)
	var desired_vel_y = scalar.Mul(direction[1], speed)
	var desired_pos_x = scalar.Add(PositionX(), scalar.Mul(desired_vel_x, game.world.dt))
	var desired_pos_y = scalar.Add(PositionY(), scalar.Mul(desired_vel_y, game.world.dt))
	if body.colliding and moving:
		print("colliding")
		var diff_x = scalar.Sub(prev_desired_pos_x, body.pos_x)
		var diff_y = scalar.Sub(prev_desired_pos_y, body.pos_y)
		var l = vector.Length(diff_x, diff_y)
		var adjust_ratio = scalar.Clamp(scalar.Div(l, scalar.Mul(speed, game.world.dt)), 0, scalar.One)
		var to_x = -desired_vel_y if diff_x < 0 else desired_vel_y
		var to_y = desired_vel_x if diff_x < 0 else -desired_vel_x
		desired_vel_x = scalar.Add(desired_vel_x, scalar.Mul(to_x, adjust_ratio))
		desired_vel_y = scalar.Add(desired_vel_y, scalar.Mul(to_y, adjust_ratio))
		var truncated = vector.Truncated(desired_vel_x, desired_vel_y, speed)
		desired_vel_x = truncated[0]
		desired_vel_y = truncated[1]
		desired_pos_x = scalar.Add(PositionX(), scalar.Mul(desired_vel_x, game.world.dt))
		desired_pos_y = scalar.Add(PositionY(), scalar.Mul(desired_vel_y, game.world.dt))
	else:
		print("not colliding")
	SetPosition(desired_pos_x, desired_pos_y)
	charge += 1
	prev_desired_pos_x = desired_pos_x
	prev_desired_pos_y = desired_pos_y
	
	# client only
	set_rot(desired_vel_x, desired_vel_y)
	if charge == 1:
		if $AnimationPlayer.current_animation != "move_human":
			$AnimationPlayer.play("move_human")
	if charge == chargeDelay():
		$AnimationPlayer.play("skill_charge")

func handleAttack():
	if charged():
		if attack == 0:
			$AnimationPlayer.play("skill_attack")
		var t = target()
		if t != null:
			look_at_pos(t.PositionX(), t.PositionY())
		if attack == chargedAttackPreDelay():
			if t != null and withinRange(t):
				t.TakeDamage(chargedAttackDamage(), self)
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
			$AnimationPlayer.play("attack")
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

func chargeDelay():
	return stat.units[name_]["chargedelay"]

func chargedMoveSpeed():
	var s = stat.units[name_]["chargedmovespeed"]
	return game.World().FromPixel(s)

func chargedAttackDamage():
	var v = stat.units[name_]["chargedattackdamage"]
	var t = typeof(v)
	if t == TYPE_INT:
		return v
	if t == TYPE_ARRAY:
		return v[level]
	print("invalid charged attack damage type")

func chargedAttackInterval():
	return stat.units[name_]["chargedattackinterval"]

func chargedAttackPreDelay():
	return stat.units[name_]["chargedattackpredelay"]

func charged():
	return charge >= chargeDelay()
