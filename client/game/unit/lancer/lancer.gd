extends "res://game/script/unit.gd"

var TileOccupier = preload("res://game/script/tileoccupier.gd")

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

func Init(id, level, posX, posY, game, player):
	New(id, "lancer", player.Team(), level, posX, posY, game)
	self.player = player
	var hp = initialHp()
	var divider = 1
	var ratios = player.StatRatios("hpratio")
	for i in range(len(ratios)):
		hp *= ratios[i]
		divider *= 100
	self.hp = hp / divider
	set_hp()
	TileOccupier = TileOccupier.new(game)
	var tile = game.TileFromPos(posX, posY)
	var tr = { "t":tile[1]-2, "b":tile[1]+1, "l":tile[0]-2, "r":tile[0]+1 }
	var err = TileOccupier.Occupy(tr)
	if err != null:
		print(err)
		return
	initPosX = PositionX()
	initPosY = PositionY()
	var offsetX = scalar.Mul(game.Map().TileWidth(), scalar.FromInt(stat.HoverKnightTileOffsetX))
	minPosX = scalar.Sub(initPosX, offsetX)
	maxPosX = scalar.Add(initPosX, offsetX)

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
	TileOccupier.Release()
	$AnimationPlayer.play("destroy")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func attackDamage():
	var damage = .attackDamage()
	var divider = 1
	var ratios = player.StatRatios("attackdamageratio")
	for i in range(len(ratios)):
		damage *= ratios[i]
		divider *= 100
	return damage / divider

func attackRange():
	var atkrange = stat.units[name_]["attackrange"]
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
	
func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack")
		$Sound/sound_fire.play()
	if attack == preAttackDelay():
		var t = target()
		if t != null and withinRange(t):
			fire()
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0

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
	var damage = s["damage"]
	var duration = s["duration"]
	for i in count:
		var x = game.World().FromPixel(posX[i])
		var y = game.World().FromPixel(posY[i])
		var dot = $ResourcePreloader.get_resource("deathcarpet").instance()
		dot.Init(team, x, y, w, h, damage, duration, game)
		game.AddSkill(dot)

func Skill():
	var key = "leader" if isLeader else "wing"
	return stat.units[name_]["skill"][key]

func CastSkill(posX, posY):
	if cast > 0:
		return false
	attack = 0
	cast += 1
	castPosX = posX
	castPosY = posY
	rotate_to_cast_pos()
	$AnimationPlayer.play("skill")
	setLayer("Casting")
	return true

func rotate_to_cast_pos():
	var x = game.World().FromPixel(castPosX)
	var y = game.World().FromPixel(castPosY)
	var vX = game.World().ToPixel(scalar.Sub(x, PositionX()))
	var vY = game.World().ToPixel(scalar.Sub(y, PositionY()))
	$Rotatable.rotation = Vector2(vX, vY).angle() + PI/2
	if game.team_swapped:
		$Rotatable.rotation += PI
	
func drop():
	var dps = Skill()["damage"]
	var w = game.World().FromPixel(Skill()["width"])
	var h = game.World().FromPixel(Skill()["height"])
	var remain = Skill()["damageduration"]
	var x = game.World().FromPixel(castPosX)
	var y = game.World().FromPixel(castPosY)
	var dot = $ResourcePreloader.get_resource("napalm").instance()
	dot.Init(team, x, y, w, h, dps, remain, game)
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
	b.Init(targetId, bulletLifeTime(), attackDamage(), game)
	var duration = 0
	for d in player.StatRatios("slowduration"):
		duration += d
	b.MakeFrozen(duration)
	game.AddBullet(b)
	
	# client only
	b.global_position = $Rotatable/Shotpoint.global_position
