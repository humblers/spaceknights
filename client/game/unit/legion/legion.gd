extends "res://game/script/unit.gd"

var TileOccupier = preload("res://game/script/tileoccupier.gd")

var player
var isLeader = false
var targetId = 0
var attack = 0
var cast = 0
var castPosX = 0
var castPosY = 0

var attack_counter = 0

func _ready():
	var dup = $AnimationPlayer.get_animation("skill").duplicate()
	$AnimationPlayer.rename_animation("skill", "skill-ref")
	$AnimationPlayer.add_animation("skill", dup)

func Init(id, level, posX, posY, game, player):
	.Init(id, "legion", player.Team(), level, posX, posY, game)
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
	if freeze > 0:
		attack = 0
		targetId = 0
		freeze -= 1
		return
	if cast > 0:
		if cast == preCastDelay() + 1:
			fireball()
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
	if target() == null and cast == 0:
		$AnimationPlayer.play("idle")

func findTargetAndAttack():
	var t = findTarget()
	setTarget(t)
	if t != null and withinRange(t):
		handleAttack()

func castDuration():
	return stat.cards[Skill()]["castduration"]

func preCastDelay():
	return stat.cards[Skill()]["precastdelay"]

func SetAsLeader():
	isLeader = true
	var data = stat.passives[Skill()]
	player.AddStatRatio("attackdamageratio", data["attackdamageratio"][level])

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
	init_rotation()
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

func fireball():
	var damage = stat.cards[Skill()]["damage"][level]
	var radius = game.World().FromPixel(stat.cards[Skill()]["radius"])
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		var x = scalar.Sub(game.World().FromPixel(castPosX), u.PositionX())
		var y = scalar.Sub(game.World().FromPixel(castPosY), u.PositionY())
		var d = vector.LengthSquared(x, y)
		var r = scalar.Add(Radius(), radius)
		if d < scalar.Mul(r, r):
			u.TakeDamage(damage, "Skill")
	
	# client only
	var skill = resource.SKILL[name_].instance()
	game.get_node("Skills").add_child(skill)
	skill.position = Vector2(castPosX, castPosY)
	skill.z_index = Z_INDEX["Skill"]
	game.camera.Shake(1, 60, 16)

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
		$Sound/sound_fire.play()
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
	var duration = 0
	for d in player.StatRatios("slowduration"):
		duration += d
	b.MakeFrozen(duration)
	game.AddBullet(b)
	
	# client only
	if attack_counter % 2 == 0:
		b.global_position = $Rotatable/Body/ShoulderL/ArmL/ShotpointL.global_position
	else:
		b.global_position = $Rotatable/Body/ShoulderR/ArmR/ShotpointR.global_position
	attack_counter += 1
