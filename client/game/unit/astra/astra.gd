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

func _ready():
	var dup = $AnimationPlayer.get_animation("skill").duplicate()
	$AnimationPlayer.rename_animation("skill", "skill-ref")
	$AnimationPlayer.add_animation("skill", dup)

func Init(id, level, posX, posY, game, player):
	.Init(id, "astra", player.Team(), level, posX, posY, game)
	self.player = player
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
	$AnimationPlayer.play("explosion")
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
	if cast > 0:
		if cast > laserStart() and cast <= laserEnd():
			deal()
		if cast > laserDuration():
			cast = 0
			setLayer(initialLayer())
			z_index = Z_INDEX[.Layer()]
		else:
			cast += 1
	else:
		if target() == null:
			setTarget(findTarget())
			attack = 0
		var t = target()
		if t != null and canSee(t):
			var posX = scalar.Clamp(t.PositionX(), minPosX, maxPosX)
			moveTo(posX, PositionY())
			if withinRange(t):
				if attack % attackInterval() == 0:
					t.TakeDamage(attackDamage(), "Range")
				attack += 1
			else:
				attack = 0
		else:
			moveTo(initPosX, initPosY)
			attack = 0
		
	# client only
	show_laser(attack > 0)

func show_laser(enable):
	for pos in ["L", "R", "C"]:
		var n = get_node("Rotatable/Body/Shotpoint%s" % pos)
		n.visible = enable
		if enable:
			var from = n.global_position
			var to = (from - target().global_position).normalized()
			to = to * game.World().ToPixel(target().Radius())
			to = target().global_position + to
			n.get_node("HitPoint").global_position = to
			var beam = n.get_node("LaserBeam")
			beam.global_scale.y = (to - from).length() / beam.texture.get_height()
			beam.global_rotation = (to - from).angle() + PI/2

func deal():
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		if inLaserArea(u):
			u.TakeDamage(laserDamage(), "Skill")
	
func laserDuration():
	return stat.cards[Skill()]["duration"]

func laserStart():
	return stat.cards[Skill()]["start"]

func laserEnd():
	return stat.cards[Skill()]["end"]

func laserDamage():
	var v = stat.cards[Skill()]["damage"]
	var t = typeof(v)
	if t == TYPE_INT:
		return v
	if t == TYPE_ARRAY:
		return v[level]
	print("invalid laser damage type")

func laserWidth():
	return game.World().FromPixel(stat.cards[Skill()]["width"])

func laserHeight():
	return game.World().FromPixel(stat.cards[Skill()]["height"])

func inLaserArea(unit):
	var centerX = game.World().FromPixel(castPosX)
	var centerY = scalar.Sub(game.World().FromPixel(castPosY), laserHeight())
	if boxVScircle(
		centerX,
		centerY,
		unit.PositionX(),
		unit.PositionY(),
		laserWidth(),
		laserHeight(),
		unit.Radius()):
			return true
	return false

func SetAsLeader():
	isLeader = true
	var data = stat.passives[Skill()]
	player.AddStatRatio("hpratio", data["hpratio"][level])
	var hp = initialHp()
	var divider = 1
	var ratios = player.StatRatios("hpratio")
	for i in range(len(ratios)):
		hp *= ratios[i]
		divider *= 100
	self.hp = hp / divider
	set_hp()

func Skill():
	var key = "passive" if isLeader else "active"
	return stat.units[name_][key]

func CastSkill(posX, posY):
	if cast > 0:
		return false
	attack = 0
	cast += 1
	castPosX = posX
	castPosY = posY
	adjustSkillAnim()
	$AnimationPlayer.play("skill")
	setLayer("Casting")
	return true

func adjustSkillAnim():
	var ref_vec = Vector2(0, -800) * $Rotatable.scale
	var x = game.World().ToPixel(scalar.Sub(game.World().FromPixel(castPosX), PositionX()))
	var y = game.World().ToPixel(scalar.Sub(game.World().FromPixel(castPosY), PositionY()))
	var vec = Vector2(x, y).rotated($Rotatable.rotation)
	var angle = ref_vec.angle_to(vec)
	var scale = vec.length()/ref_vec.length()
	var old_anim = $AnimationPlayer.get_animation("skill-ref")
	var new_anim = $AnimationPlayer.get_animation("skill")
	var track_idx = old_anim.find_track("Rotatable/Body:position")
	var key_count = old_anim.track_get_key_count(track_idx)
	for i in range(key_count):
		var v = old_anim.track_get_key_value(track_idx, i)
		new_anim.track_set_key_value(track_idx, i, v.rotated(angle) * scale)

func target():
	return game.FindUnit(targetId)
	
func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()

func boxVScircle(posAx, posAy, posBx, posBy, width, height, radius):
	var relPosX = scalar.Sub(posBx, posAx)
	var relPosY = scalar.Sub(posBy, posBy)
	var closestX = relPosX
	var closestY = relPosY
	var xExtent = width
	var yExtent = height
	closestX = scalar.Clamp(closestX, -xExtent, xExtent)
	closestY = scalar.Clamp(closestY, -yExtent, yExtent)
	if relPosX == closestX and relPosY == closestY:
		return false
	var normalX = scalar.Sub(relPosX, closestX)
	var normalY = scalar.Sub(relPosY, closestY)
	var d = vector.LengthSquared(normalX, normalY)
	if d > scalar.Mul(radius, radius):
		return false
	return true
	
