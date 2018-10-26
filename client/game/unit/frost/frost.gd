extends "res://game/script/unit.gd"

var TileOccupier = preload("res://game/script/tileoccupier.gd")

var player
var isLeader = false
var targetId = 0
var attack = 0
var cast = 0
var castPosX = 0
var castPosY = 0

const ROT_SPEED = PI/4
onready var arm_l = $Rotatable/Body/Main/ShoulderL/UpperarmL/ArmL
onready var arm_r = $Rotatable/Body/Main/ShoulderR/UpperarmR/ArmR
onready var init_rot = $Rotatable.global_rotation

func Init(id, level, posX, posY, game, player):
	New(id, "frost", player.Team(), level, posX, posY, game)
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
	
	# client only
	var dup = $AnimationPlayer.get_animation("skill").duplicate()
	$AnimationPlayer.rename_animation("skill", "skill-ref")
	$AnimationPlayer.add_animation("skill", dup)

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
			doFreeze()
		if cast > castDuration():
			cast = 0
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
		cancel_aim()

func castDuration():
	return Skill()["castduration"]

func preCastDelay():
	return Skill()["precastdelay"]

func SetAsLeader():
	isLeader = true
	player.AddStatRatio("slowduration", Skill()["slowduration"][level])

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
	init_rotation()
	adjustSkillAnim()
	$AnimationPlayer.play("skill")
	setLayer("Casting")
	return true

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
	var duration = castDuration() - preCastDelay()
	var radius = game.World().FromPixel(Skill()["radius"])
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		var x = scalar.Sub(game.World().FromPixel(castPosX), u.PositionX())
		var y = scalar.Sub(game.World().FromPixel(castPosY), u.PositionY())
		var d = vector.LengthSquared(x, y)
		var r = scalar.Add(Radius(), radius)
		if d < scalar.Mul(r, r):
			u.Freeze(duration)
	
	# client only
	var skill = $ResourcePreloader.get_resource("freeze").instance()
	game.get_node("Skills").add_child(skill)
	var pos = Vector2(castPosX, castPosY)
	if game.team_swapped:
		pos.x = game.FlipX(pos.x)
		pos.y = game.FlipY(pos.y)
	skill.position = pos
	skill.z_index = Z_INDEX["Skill"]

func target():
	return game.FindUnit(targetId)
	
func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()
	
func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack")
		$Sound/sound_fire.play()
	var t = target()
	if t != null:
		aim(t)
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			fire()
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0

func aim(t):
	var angle = (t.global_position - $Rotatable.global_position).angle() + PI/2
	var angle_l = (t.global_position - arm_l.global_position).angle() + PI/2
	var angle_r = (t.global_position - arm_r.global_position).angle() + PI/2
	var diff = angle_diff(angle, $Rotatable.global_rotation)
	var diff_l = angle_diff(angle_l, arm_l.global_rotation)
	var diff_r = angle_diff(angle_r, arm_r.global_rotation)
	var max_rot = ROT_SPEED/game.STEP_PER_SEC
	$Rotatable.global_rotation += clamp(diff, -max_rot, max_rot)
	arm_l.global_rotation += clamp(diff_l, -max_rot, max_rot)
	arm_r.global_rotation += clamp(diff_r, -max_rot, max_rot)

func cancel_aim():
	var diff = angle_diff(init_rot, $Rotatable.global_rotation)
	var diff_l = angle_diff(init_rot, arm_l.global_rotation)
	var diff_r = angle_diff(init_rot, arm_r.global_rotation)
	var max_rot = ROT_SPEED/game.STEP_PER_SEC
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

	b.Init(targetId, bulletLifeTime(), attackDamage(), game)
	var duration = 0
	for d in player.StatRatios("slowduration"):
		duration += d
	b.MakeFrozen(duration)
	game.AddBullet(b)
