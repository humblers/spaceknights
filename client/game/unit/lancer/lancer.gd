extends "res://game/script/unit.gd"

var player
var isLeader = false
var targetId = 0
var attack = 0
var cast = 0
var initPosX = 0
var initPosY = 0
var minPosX = 0
var maxPosX = 0
var castPosX = 0
var castPosY = 0
var retargeting = false

func Init(id, level, posX, posY, game, player):
	New(id, "lancer", player.Team(), level, posX, posY, game)
	self.player = player
	var tile = game.TileFromPos(posX, posY)
	var tr = game.NewTileRect(
		tile[0],
		tile[1],
		player.KNIGHT_TILE_NUM_X,
		player.KNIGHT_TILE_NUM_Y
	)
	.Occupy(tr)
	initPosX = PositionX()
	initPosY = PositionY()
	var offsetX = scalar.Mul(game.Map().TileWidth(), scalar.FromInt(data.HoverKnightTileOffsetX))
	minPosX = scalar.Sub(initPosX, offsetX)
	maxPosX = scalar.Add(initPosX, offsetX)

func TakeDamage(amount, damageType, attacker):
	var initHp = InitialHp()
	var underHalf = initHp / 2 > hp
	if damageType in [data.Skill, data.Death]:
		amount = amount * data.ReducedDamgeRatioOnKnightBuilding / 100
	.TakeDamage(amount, damageType, attacker)
	if not underHalf and initHp / 2 > hp:
		player.OnKnightHalfDamaged(self)
	if IsDead():
		player.OnKnightDead(self)

func Destroy():
	.Destroy()
	.Release()
	$AnimationPlayer.play("destroy")
	game.camera.Shake(1, 60, 20)
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func attackDamage():
	var damage = .attackDamage()
	var divider = 1
	var ratios = player.StatRatios("attackdamageratio")
	for i in range(len(ratios)):
		damage *= ratios[i]
		divider *= 100
	damage /= divider
	var amplifies = player.StatRatios("amplifydamagepersec")
	var limits = player.StatRatios("amplifycountlimit")
	for i in range(len(amplifies)):
		var cnt = attack / data.StepPerSec
		if cnt > limits[i]:
			cnt = limits[i]
		damage += amplifies[i] * cnt * attackInterval() / data.StepPerSec
	return damage

func attackRange():
	var atkrange = data.units[name_]["attackrange"]
	var divider = 1
	var ratios = player.StatRatios("attackrangeratio")
	for i in range(len(ratios)):
		atkrange *= ratios[i]
		divider *= 100
	atkrange /= divider
	return game.World().FromPixel(atkrange)

func Update():
	if freeze > 0:
		attack = 0
		targetId = 0
		freeze -= 1
		return
	if cast > 0:
		if cast == preCastDelay() + 1:
			drop()
		if cast > castDuration():
			cast = 0
			init_rotation()
			setLayer(initialLayer())
			z_index = Z_INDEX[.Layer()]
		else:
			cast += 1
	else:
		if attack > 0 and not retargeting:
			handleAttack()
		else:
			var t = target()
			if t == null:
				attack = 0
				findTargetAndDoAction()
			else:
				if withinRange(t):
					handleAttack()
				else:
					attack = 0
					findTargetAndDoAction()
	
func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack")
	if attack % attackInterval() == preAttackDelay():
		var t = target()
		if t != null and withinRange(t):
			fire()
		else:
			retargeting = true
			return
	if attack > 0 and attack % attackInterval() == 0:
		retargeting = true
	attack += 1

func findTargetAndDoAction():
	var t = findTarget()
	setTarget(t)
	if t != null:
		if withinRange(t):
			handleAttack()
		else:
			var posX = scalar.Clamp(t.PositionX(), minPosX, maxPosX)
			moveToPos(posX, PositionY())
	else:
		moveToPos(initPosX, initPosY)

func castDuration():
	return Skill()["castduration"]

func preCastDelay():
	return Skill()["precastdelay"]

func SetAsLeader():
	isLeader = true
	var s = Skill()
	var count = s["count"]
	var posX = s["posX"]
	var posY = s["posY"]
	var w = game.World().FromPixel(s["width"])
	var h = game.World().FromPixel(s["height"])
	var damage = s["damage"][level]
	var damageType = s["damagetype"]
	var duration = s["duration"]
	for i in count:
		var x = game.World().FromPixel(posX[i])
		var y = game.World().FromPixel(posY[i])
		var dot = $ResourcePreloader.get_resource("deathcarpet").instance()
		dot.Init(team, x, y, w, h, damage, duration, damageType, game)
		game.AddSkill(dot)

func Skill():
	var key = "leader" if isLeader else "wing"
	return data.units[name_]["skill"][key]

func CanCastSkill():
	return cast <= 0

func CastSkill(posX, posY):
	attack = 0
	cast += 1
	castPosX = posX
	castPosY = posY
	rotate_to_cast_pos()
	$AnimationPlayer.play("skill")
	setLayer(data.Casting)

func rotate_to_cast_pos():
	var x = game.World().FromPixel(castPosX)
	var y = game.World().FromPixel(castPosY)
	var vX = game.World().ToPixel(scalar.Sub(x, PositionX()))
	var vY = game.World().ToPixel(scalar.Sub(y, PositionY()))
	$Rotatable.rotation = Vector2(vX, vY).angle() + PI/2
	if game.team_swapped:
		$Rotatable.rotation += PI
	
func drop():
	var dps = Skill()["damage"][level]
	var w = game.World().FromPixel(Skill()["width"])
	var h = game.World().FromPixel(Skill()["height"])
	var remain = Skill()["damageduration"]
	var x = game.World().FromPixel(castPosX)
	var y = game.World().FromPixel(castPosY)
	var dot = $ResourcePreloader.get_resource("napalm").instance()
	var damageType = Skill()["damagetype"]
	dot.Init(team, x, y, w, h, dps, remain, damageType, game)
	game.AddSkill(dot)

func target():
	return game.FindUnit(targetId)
	
func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()

func fire():
	var b = $ResourcePreloader.get_resource("missile").instance()
	b.Init(targetId, bulletLifeTime(), attackDamage(), damageType(), game)
	var duration = 0
	for d in player.StatRatios("slowduration"):
		duration += d
	b.MakeFrozen(duration)
	var damageRadius = 0
	for r in player.StatRatios("expanddamageradius"):
		damageRadius += scalar.Add(damageRadius, game.World().FromPixel(r))
	b.MakeSplash(damageRadius)
	game.AddBullet(b)
	
	# client only
	b.rotation = $Rotatable.rotation
	b.global_position = $Rotatable/Shotpoint.global_position
