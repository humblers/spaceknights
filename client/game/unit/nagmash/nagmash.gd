extends "res://game/script/unit.gd"

var player
var targetId = 0
var attack = 0
var cast = 0
var initPosX = 0
var initPosY = 0
var castPosX = 0
var castPosY = 0

func _ready():
	var dup = $AnimationPlayer.get_animation("skill").duplicate()
	$AnimationPlayer.rename_animation("skill", "skill-ref")
	$AnimationPlayer.add_animation("skill", dup)

func InitDummy(posX, posY, game, player):
	.InitDummy("nagmash", player.Team(), posX, posY, game)

func Init(id, level, posX, posY, game, player):
	.Init(id, "nagmash", player.Team(), level, posX, posY, game)
	self.player = player
	initPosX = PositionX()
	initPosY = PositionY()

func TakeDamage(amount, attackType):
	.TakeDamage(amount, attackType)
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
			spawn()
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
		chaseTarget()

func chaseTarget():
	var t = target()
	if t != null and canSee(t):
		moveTo(t.PositionX(), PositionY())
	else:
		moveTo(initPosX, initPosY)

func castDuration():
	return stat.cards[Skill()]["castduration"]

func preCastDelay():
	return stat.cards[Skill()]["precastdelay"]
		
func findTargetAndAttack():
	var t = findTarget()
	setTarget(t)
	if t != null and withinRange(t):
		handleAttack()
	else:
		$AnimationPlayer.play("idle")

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

func spawn():
	var card = stat.cards[Skill()]
	var name = card["unit"]
	var count = card["count"]
	var offsetX = card["offsetX"]
	var offsetY = card["offsetY"]
	for i in range(count):
		game.AddUnit(name, level, castPosX+offsetX[i], castPosY+offsetY[i], player)

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
	var t = target()
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
	b.global_position = $Rotatable/Body/ShotpointL.global_position
