extends "res://game/script/unit.gd"

var player
var isLeader = false
var targetId = 0
var attack = 0
var cast = 0
var castPosX = 0
var castPosY = 0
var retargeting = false

var skillReady = false

const ROT_SPEED = PI/4
onready var arm_l = $Rotatable/Body/Main/ShoulderL/UpperarmL/ArmL
onready var arm_r = $Rotatable/Body/Main/ShoulderR/UpperarmR/ArmR
onready var init_rot = $Rotatable.global_rotation

func Init(id, level, posX, posY, game, player):
	New(id, "frost", player.Team(), level, posX, posY, game)
	self.player = player
	var tile = game.TileFromPos(posX, posY)
	var tr = game.NewTileRect(
		tile[0],
		tile[1],
		player.KNIGHT_TILE_NUM_X,
		player.KNIGHT_TILE_NUM_Y
	)
	.Occupy(tr)
	
	# client only
	var dup = $AnimationPlayer.get_animation("skill").duplicate()
	$AnimationPlayer.rename_animation("skill", "skill-ref")
	$AnimationPlayer.add_animation("skill", dup)

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
			doFreeze()
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

func findTargetAndAttack():
	var t = findTarget()
	setTarget(t)
	if t != null and withinRange(t):
		handleAttack()
	else:
		cancel_aim()

func castDuration():
	return Skill()["castduration"]

func preCastDelay():
	return Skill()["precastdelay"]

func freezeDuration():
	return Skill()["freezeduration"]

func SetAsLeader():
	isLeader = true
	player.AddStatRatio("slowduration", Skill()["slowduration"][level])

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
	init_rotation()
	adjustSkillAnim()
	$AnimationPlayer.play("skill")
	setLayer(data.Casting)

func adjustSkillAnim():
	var ref_vec = Vector2(0, -800)
	var x = game.World().ToPixel(scalar.Sub(game.World().FromPixel(castPosX), PositionX()))
	var y = game.World().ToPixel(scalar.Sub(game.World().FromPixel(castPosY), PositionY()))
	var vec = Vector2(x, y).rotated($Rotatable.rotation)
	if game.team_swapped:
		vec = vec.rotated(PI)
	var angle = ref_vec.angle_to(vec)
	var scale = vec.length()/ref_vec.length()
	var old_anim = $AnimationPlayer.get_animation("skill-ref")
	var new_anim = $AnimationPlayer.get_animation("skill")
	var track_idx = old_anim.find_track("Rotatable/Body:position")
	var key_count = old_anim.track_get_key_count(track_idx)
	for i in range(key_count):
		var v = old_anim.track_get_key_value(track_idx, i)
		new_anim.track_set_key_value(track_idx, i, v.rotated(angle) * scale)

func doFreeze():
	var duration = freezeDuration()
	var radius = game.World().FromPixel(Skill()["radius"])
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		var x = scalar.Sub(u.PositionX(), game.World().FromPixel(castPosX))
		var y = scalar.Sub(u.PositionY(), game.World().FromPixel(castPosY))
		var d = vector.LengthSquared(x, y)
		var r = scalar.Add(u.Radius(), radius)
		if d < scalar.Mul(r, r):
			u.Freeze(duration)
	
	# client only
	var skill = $ResourcePreloader.get_resource("freeze").instance()
	game.AddSkill(skill, false)
	var pos = Vector2(castPosX, castPosY)
	if game.team_swapped:
		pos.x = game.FlipX(pos.x)
		pos.y = game.FlipY(pos.y)
	skill.position = pos

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
		aim(t)
	if modulo == preAttackDelay():
		if t != null and withinRange(t):
			fire()
		else:
			retargeting = true
			return
	retargeting = attack > 0 and modulo == 0
	attack += 1

func aim(t):
	var angle = (t.global_position - $Rotatable.global_position).angle() + PI/2
	var angle_l = (t.global_position - arm_l.global_position).angle() + PI/2
	var angle_r = (t.global_position - arm_r.global_position).angle() + PI/2
	var diff = angle_diff(angle, $Rotatable.global_rotation)
	var diff_l = angle_diff(angle_l, arm_l.global_rotation)
	var diff_r = angle_diff(angle_r, arm_r.global_rotation)
	var max_rot = ROT_SPEED/data.StepPerSec
	$Rotatable.global_rotation += clamp(diff, -max_rot, max_rot)
	arm_l.global_rotation += clamp(diff_l, -max_rot, max_rot)
	arm_r.global_rotation += clamp(diff_r, -max_rot, max_rot)

func cancel_aim():
	var diff = angle_diff(init_rot, $Rotatable.global_rotation)
	var diff_l = angle_diff(init_rot, arm_l.global_rotation)
	var diff_r = angle_diff(init_rot, arm_r.global_rotation)
	var max_rot = ROT_SPEED/data.StepPerSec
	$Rotatable.global_rotation += clamp(diff, -max_rot, max_rot)
	arm_l.global_rotation += clamp(diff_l, -max_rot, max_rot)
	arm_r.global_rotation += clamp(diff_r, -max_rot, max_rot)
	
static func angle_diff(a, b):
	return fposmod((a - b) + PI, 2 * PI) - PI
	
func fire():
	var b = $ResourcePreloader.get_resource("bullet").instance()

	# client only
	b.BULLET_COUNT = 6
	b.spawnerId = Id()
	b.shotpoints["Left"] = "Rotatable/Body/Main/ShoulderL/UpperarmL/ArmL/ShotpointL"
	b.shotpoints["Right"] = "Rotatable/Body/Main/ShoulderR/UpperarmR/ArmR/ShotpointR"

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

func skillReady():
	get_node("AnimationPlayer").play("skill_ready")
	skillReady = true
	
func skillRest():
	get_node("AnimationPlayer").play("idle")
	skillReady = false