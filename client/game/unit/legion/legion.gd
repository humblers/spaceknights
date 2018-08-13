extends "res://game/script/unit.gd"

var player
var targetId = 0
var attack = 0
var transform_ = 0
var initPosX = 0
var initPosY = 0
var castPosX = 0
var castPosY = 0
var isCasting = false
var movingToCastPos = false

var attack_counter = 0

func Init(id, level, posX, posY, game, player):
	.Init(id, "legion", player.Team(), level, posX, posY, game)
	self.player = player
	initPosX = PositionX()
	initPosY = PositionY()

func TakeDamage(amount, attackType):
	var initHp = initialHp()
	var underHalf = initHp / 2 > hp
	.TakeDamage(amount, attackType)
	if not underHalf and initHp / 2 > hp:
		player.OnKnightHalfDamaged(self)
	if IsDead():
		player.OnKnightDead(self)

func Destroy():
	.Destroy()
	$AnimationPlayer.play("explosion")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
	
func Update():
	if isCasting:
		if movingToCastPos:
			if transform_ >= transformDelay():
				if PositionX() == castPosX and PositionY() == castPosY:
					cast()
					movingToCastPos = false
				else:
					var x = scalar.Sub(castPosX, PositionX())
					var y = scalar.Sub(castPosY, PositionY())
					var s = scalar.Mul(game.World().Dt(), speed())
					var l = vector.LengthSquared(x, y)
					if l <= scalar.Mul(s, s):
						SetVelocity(0, 0)
						SetPosition(castPosX, castPosY)
					else:
						l = scalar.Sqrt(l)
						var d = scalar.Div(speed(), l)
						SetVelocity(scalar.Mul(x, d), scalar.Mul(y, d))
			else:
				if transform_ == 0:
					$AnimationPlayer.play("transform")
				transform_ += 1
		else:
			if PositionX() == initPosX and PositionY() == initPosY:
				if transform_ == transformDelay():
					$AnimationPlayer.play_backwards("transform")
				if transform_ > 0:
					transform_ -= 1
				else:
					z_index = Z_INDEX[.Layer()]
					isCasting = false
					setLayer(initialLayer())
			else:
				var x = scalar.Sub(initPosX, PositionX())
				var y = scalar.Sub(initPosY, PositionY())
				var s = scalar.Mul(game.World().Dt(), speed())
				var l = vector.LengthSquared(x, y)
				if l <= scalar.Mul(s, s):
					SetVelocity(0, 0)
					SetPosition(initPosX, initPosY)
				else:
					l = scalar.Sqrt(l)
					var d = scalar.Div(speed(), l)
					SetVelocity(scalar.Mul(x, d), scalar.Mul(y, d))
	else:
		if attack > 0:
			handleAttack()
		else:
			var t = target()
			if t == null:
				findTargetAndAttack()
			else:
				if withinRange(t):
					handleAttack()
				else:
					findTargetAndAttack()
	if target() == null and not isCasting and not $AnimationPlayer.current_animation == "show":
		$AnimationPlayer.play("idle")

func findTargetAndAttack():
	var t = findTarget()
	setTarget(t)
	if t != null and withinRange(t):
		handleAttack()

func CastSkill(posX, posY):
	if isCasting:
		return false
	attack = 0
	isCasting = true
	movingToCastPos = true
	castPosX = game.World().FromPixel(posX)
	castPosY = game.World().FromPixel(posY)
	setLayer("Casting")
	init_rotation()
	return true

func cast():
	var damage = stat.cards[Skill()]["damage"][level]
	var radius = game.World().FromPixel(stat.cards[Skill()]["radius"])
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		var d = squaredDistanceTo(u)
		var r = scalar.Add(Radius(), radius)
		if d < scalar.Mul(r, r):
			u.TakeDamage(damage, "Skill")
	
	# client only
	var skill = resource.SKILL[name_].instance()
	game.get_node("Skills").add_child(skill)
	skill.position = position
	skill.z_index = Z_INDEX["Skill"]
	var anim = skill.get_node("AnimationPlayer")
	anim.play("explosion")
	yield(anim, "animation_finished")
	skill.queue_free()

func target():
	return game.FindUnit(targetId)
	
func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()
	
func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack_%s" % ((attack_counter % 2) + 1))
	var t = target()
	if t != null:
		look_at(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			fire()
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0

func fire():
	var b = resource.BULLET[name_].instance()
	b.Init(targetId, bulletLifeTime(), attackDamage(), game)
	game.AddBullet(b)
	
	# client only
	if attack_counter % 2 == 0:
		b.global_position = $Rotatable/Main/ShoulderL/ArmL/ShotpointL.global_position
	else:
		b.global_position = $Rotatable/Main/ShoulderR/ArmR/ShotpointR.global_position
	attack_counter += 1
