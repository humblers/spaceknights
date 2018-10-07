extends "res://game/script/unit.gd"

var targetId = 0
var attack = 0
var charge = 0
var shield

func Init(id, level, posX, posY, game, player):
	New(id, "champion", player.Team(), level, posX, posY, game)
	shield = initialShield()
	$Hp/Shield.max_value = shield
	$Hp/Shield.value = shield
	
func TakeDamage(amount, attackType):
	if attackType != "Melee":
		shield -= amount
		if shield < 0:
			hp += shield
			shield = 0
		$Energyshield/EnergyShieldAni.play("energyshield")
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
		charge = 0

func moveTo(unit):
	var corner = game.Map().FindNextCornerInPath(
		PositionX(), PositionY(),
		unit.PositionX(), unit.PositionY(),
		Radius())
	var x = scalar.Sub(corner[0], PositionX())
	var y = scalar.Sub(corner[1], PositionY())
	var direction = vector.Normalized(x, y)
	var speed = speed()
	if charged():
		speed = chargedMoveSpeed()
	SetVelocity(
		scalar.Mul(direction[0], speed), 
		scalar.Mul(direction[1], speed))
	charge += 1
	
	# client only
	look_at_pos(corner[0], corner[1])
	if charge == 1:
		if $AnimationPlayer.current_animation != "move_human":
			$AnimationPlayer.play("move_human")
	if charge == chargeDelay():
		$AnimationPlayer.play("skill_charge")

func handleAttack():
	if charged():
		if attack == 0:
			$AnimationPlayer.play("skill_attack")
			$Sound/sound_fire.play()
		var t = target()
		if t != null:
			look_at_pos(t.PositionX(), t.PositionY())
		if attack == chargedAttackPreDelay():
			if t != null and withinRange(t):
				t.TakeDamage(chargedAttackDamage(), "Melee")
			else:
				attack = 0
				return
		attack += 1
		if attack > chargedAttackInterval():
			attack = 0
			charge = 0
	else:
		charge = 0			# prevent charge accumulation
		if attack == 0:
			$AnimationPlayer.play("attack")
			$Sound/sound_fire.play()
		var t = target()
		if t != null:
			look_at_pos(t.PositionX(), t.PositionY())
		if attack == preAttackDelay():
			if t != null and withinRange(t):
				t.TakeDamage(attackDamage(), "Melee")
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
