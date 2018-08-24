extends "res://game/script/unit.gd"

var player
var targetId = 0
var attack = 0
var cast = 0
var initPosX = 0
var initPosY = 0
var castPosX = 0
var castPosY = 0

var attack_counter = 0

func _ready():
	var dup = $AnimationPlayer.get_animation("skill").duplicate()
	$AnimationPlayer.rename_animation("skill", "skill-ref")
	$AnimationPlayer.add_animation("skill", dup)

func InitDummy(posX, posY, game, player):
	.InitDummy("legion", player.Team(), posX, posY, game)

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

func Skill():
	return stat.units[name_]["active"]

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
	var ref_vec = Vector2(0, -800)
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
	var anim = skill.get_node("AnimationPlayer")
	anim.play("explosion")
	game.camera.Shake(1, 60, 16)
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
		b.global_position = $Rotatable/Body/ShoulderL/ArmL/ShotpointL.global_position
	else:
		b.global_position = $Rotatable/Body/ShoulderR/ArmR/ShotpointR.global_position
	attack_counter += 1
