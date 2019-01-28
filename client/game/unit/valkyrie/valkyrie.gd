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
	New(id, "valkyrie", player.Team(), level, posX, posY, game)
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

func set_hp():
	.set_hp()
	get_node("Hp/HBoxContainer/VBoxContainer/%s/HpLabel" % color).text = "%d" % hp
	if color == "Red":
		get_node("Hp/HBoxContainer/VBoxContainer/%s" % color).visible = true

func TakeDamage(amount, damageType, attacker):
	var initHp = InitialHp()
	var underHalf = initHp / 2 > hp
	if data.DamageTypeIs(damageType, data.DecreaseOnKnight):
		amount = amount * data.DecreasedDamageRatioOnKnightBuilding / 100
	.TakeDamage(amount, damageType, attacker)
	get_node("Hp/HBoxContainer/VBoxContainer/%s/HpLabel" % color).text = "%d" % hp
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
	if isLeader and game.Step() % Skill()["perstep"] == 0:
		threatMissile()
	if cast > 0:
		if cast == preCastDelay() + 1:
			emp()
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
	var modulo = attack % attackInterval()
	if modulo == 0:
		$AnimationPlayer.play("attack")
	if modulo == preAttackDelay():
		var t = target()
		if t != null and withinRange(t):
			fire()
		else:
			retargeting = true
			return
	retargeting = attack > 0 and modulo == 0
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
	$AnimationPlayer.play("skill")
	setLayer(data.Casting)

func emp():
	var damage = Skill()["damage"][level]
	var damageType = Skill()["damagetype"]
	var radius = game.World().FromPixel(Skill()["radius"])
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		var x = scalar.Sub(game.World().FromPixel(castPosX), u.PositionX())
		var y = scalar.Sub(game.World().FromPixel(castPosY), u.PositionY())
		var d = vector.LengthSquared(x, y)
		var r = scalar.Add(u.Radius(), radius)
		if d < scalar.Mul(r, r):
			u.TakeDamage(damage, damageType, self)
	
	# client only
	var skill = $ResourcePreloader.get_resource("emp").instance()
	game.get_node("Skills").add_child(skill)
	var pos = Vector2(castPosX, castPosY)
	if game.team_swapped:
		pos.x = game.FlipX(pos.x)
		pos.y = game.FlipY(pos.y)
	skill.position = pos
	skill.z_index = Z_INDEX["Skill"]

func threatMissile():
	var skill = Skill()
	var unit = skill["unit"]
	var count = skill["count"]
	var offsetX = skill["offsetX"]
	var offsetY = skill["offsetY"]
	var posX = game.World().ToPixel(initPosX)
	var posY = game.World().ToPixel(initPosY)
	for i in count:
		game.AddUnit(unit, level, posX + offsetX[i], posY + offsetY[i], player)

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
	b.global_position = $Rotatable/Body/Missile.global_position
