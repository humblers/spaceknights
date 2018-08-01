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

func TakeDamage(amount):
	.TakeDamage(amount)
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
					var dirX = scalar.Sub(castPosX, PositionX())
					var dirY = scalar.Sub(castPosY, PositionY())
					var v = vector.Truncated(dirX, dirY, speed())
					SetVelocity(v[0], v[1])
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
					isCasting = false
			else:
				var dirX = scalar.Sub(initPosX, PositionX())
				var dirY = scalar.Sub(initPosY, PositionY())
				var v = vector.Truncated(dirX, dirY, speed())
				SetVelocity(v[0], v[1])
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

func findTargetAndAttack():
	var t = findTarget()
	setTarget(t)
	if t != null and withinRange(t):
		handleAttack()
	else:
		$AnimationPlayer.play("idle")

func CastSkill(posX, posY):
	if isCasting:
		return false
	attack = 0
	isCasting = true
	movingToCastPos = true
	castPosX = game.World().FromPixel(posX)
	castPosY = game.World().FromPixel(posY)
	init_rotation()
	return true

func cast():
	var damage = stat.cards[Skill()]["damage"]
	var radius = game.World.FromPixel(stat.cards[Skill()]["radius"])
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		var d = squaredDistanceTo(u)
		var r = scalar.Add(Radius(), radius)
		if d < scalar.Mul(r, r):
			u.TakeDamage(damage)
	
	# client only
	var skill = resource.SKILLS[name].instance()
	game.get_node("Skills").add_child(skill)
	var anim = skill.get_node("AnimationPlayer")
	anim.play()
	anim.connect("animation_finished", skill, "queue_free")

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
		attack_counter += 1
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
	b.position = position
