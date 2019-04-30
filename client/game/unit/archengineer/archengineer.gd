extends "res://game/script/unit.gd"

var player
var isLeader = false
var targetId = 0
var attack = 0
var cast = 0
var castPosX = 0
var castPosY = 0
var castTiles
var retargeting = false

var skillReady = false

func _ready():
	var dup = $AnimationPlayer.get_animation("skill").duplicate()
	$AnimationPlayer.rename_animation("skill", "skill-ref")
	$AnimationPlayer.add_animation("skill", dup)

func Init(id, level, posX, posY, game, player):
	New(id, "archengineer", player.Team(), level, posX, posY, game)
	self.player = player
	var tile = game.TileFromPos(posX, posY)
	var tr = game.NewTileRect(
		tile[0],
		tile[1],
		player.KNIGHT_TILE_NUM_X,
		player.KNIGHT_TILE_NUM_Y
	)
	.Occupy(tr)

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
		event.emit_signal("%sKnightHalfDamaged" % color, side)
	if IsDead():
		player.OnKnightDead(self)
		event.emit_signal("%sKnightDead" % color, side)

func Destroy():
	.Destroy()
	.Release()
	game.Release(castTiles, id)

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
			spawn()
		if cast > castDuration():
			cast = 0
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
				findTargetAndAttack()
			else:
				if withinRange(t):
					handleAttack()
				else:
					attack = 0
					findTargetAndAttack()
	if targetId <= 0 and cast <= 0:
		$AnimationPlayer.play("idle")

func castDuration():
	return Skill()["castduration"]

func preCastDelay():
	return Skill()["precastdelay"]
		
func findTargetAndAttack():
	var t = findTarget()
	setTarget(t)
	if t != null and withinRange(t):
		handleAttack()

func SetAsLeader():
	isLeader = true
	player.AddStatRatio("expanddamageradius", Skill()["expanddamageradius"][level])

func Skill():
	var key = "leader" if isLeader else "wing"
	return data.units[name_]["skill"][key]

func CanCastSkill():
	return cast <= 0

func CastSkill(posX, posY):
	var name = Skill()["unit"]
	var nx = data.units[name]["tilenumx"]
	var ny = data.units[name]["tilenumy"]
	var tile = game.TileFromPos(posX, posY)
	var tr = game.NewTileRect(tile[0], tile[1], nx, ny)
	game.Occupy(tr, id)
	castTiles = tr

	attack = 0
	cast += 1
	castPosX = posX
	castPosY = posY
	setLayer(data.Casting)
	
	init_rotation()
	adjustSkillAnim()
	$AnimationPlayer.play("skill")

func adjustSkillAnim():
	var offset = $Rotatable/Body/Turret.position * $Rotatable.scale
	var ref_vec = Vector2(0, -800) * $Rotatable.scale
	var x = game.World().ToPixel(scalar.Sub(game.World().FromPixel(castPosX), PositionX()))
	var y = game.World().ToPixel(scalar.Sub(game.World().FromPixel(castPosY), PositionY()))
	var vec = Vector2(x, y).rotated($Rotatable.rotation) - offset
	if game.team_swapped:
		vec = vec.rotated(PI)
	var angle = ref_vec.angle_to(vec)
	var scale = vec.length()/ref_vec.length()
	var old_anim = $AnimationPlayer.get_animation("skill-ref")
	var new_anim = $AnimationPlayer.get_animation("skill")
	var tracks = ["Rotatable/Body:position"]
	for track in tracks:
		var track_idx = old_anim.find_track(track)
		var key_count = old_anim.track_get_key_count(track_idx)
		for i in range(key_count):
			var v = old_anim.track_get_key_value(track_idx, i)
			new_anim.track_set_key_value(track_idx, i, v.rotated(angle) * scale)

func spawn():
	var name = Skill()["unit"]
	var unit = game.AddUnit(name, level, castPosX, castPosY, player)
	game.Release(castTiles, id)
	unit.Occupy(castTiles)
	castTiles = null

func target():
	return game.FindUnit(targetId)

func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()

func handleAttack():
	var modulo = attack % attackInterval()
	if modulo == 0:
		$AnimationPlayer.play("attack")
	var t = target()
	if t != null:
		look_at_pos(t.PositionX(), t.PositionY())
	if modulo == preAttackDelay():
		if t != null and withinRange(t):
			fire()
		else:
			retargeting = true
			return
	retargeting = attack > 0 and modulo == 0
	attack += 1

func fire():
	var b = $ResourcePreloader.get_resource("energy_orb").instance()
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
	b.global_position = $Rotatable/Body/Main/Gun/ShootingPoint.global_position

func skillReady():
	get_node("AnimationPlayer").play("skill_ready")
	skillReady = true
	
func skillRest():
	get_node("AnimationPlayer").play("idle")
	skillReady = false