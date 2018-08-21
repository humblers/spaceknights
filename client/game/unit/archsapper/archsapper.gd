extends "res://game/script/unit.gd"

var TileOccupier = preload("res://game/script/tileoccupier.gd")

var player
var leader = false
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
	.InitDummy("archsapper", player.Team(), posX, posY, game)

func Init(id, level, posX, posY, game, player):
	.Init(id, "archsapper", player.Team(), level, posX, posY, game)
	self.player = player
	TileOccupier = TileOccupier.new()
	TileOccupier.Init(game)
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
	if targetId <= 0 and cast <= 0:
		$AnimationPlayer.play("idle")

func castDuration():
	return stat.cards[Skill()]["castduration"]

func preCastDelay():
	return stat.cards[Skill()]["precastdelay"]
		
func findTargetAndAttack():
	var t = findTarget()
	setTarget(t)
	if t != null and withinRange(t):
		handleAttack()

func SetLeader():
	leader = true
	var data = stat.leaderskils[Skill()]
	var name = data["unit"]
	var count = data["count"]
	var xArr = data["posX"]
	var yArr = data["posY"]
	var nx = stat.units[name]["tilenumx"]
	var ny = stat.units[name]["tilenumy"]
	for i in range(count):
		var posX = xArr[i]
		var posY = yArr[i]
		if player.Team() == "Red":
			posX = game.FlipX(posX)
			posY = game.FlipY(posY)
		var id = game.AddUnit(name, level, posX, posY, player)
		var unit = game.FindUnit(id)
		var occupier = unit.get("TileOccupier")
		if occupier != null:
			var tile = game.TileFromPos(posX, posY)
			var tr = occupier.GetRect(tile[0], tile[1], nx, ny)
			var err = occupier.Occupy(tr)
			if err != null:
				print(err)
				return
		var decayable = unit.get("Decayable")
		if decayable != null:
			decayable.SetDecayOff()

func Skill():
	var key = "leaderskill" if leader else "skill"
	return stat.units[name_][key]

func CastSkill(posX, posY):
	if cast > 0:
		return false
	var name = stat.cards[Skill()]["unit"]
	var nx = stat.units[name]["tilenumx"]
	var ny = stat.units[name]["tilenumy"]
	var tile = game.TileFromPos(posX, posY)
	var tr = TileOccupier.GetRect(tile[0], tile[1], nx, ny)
	var err = TileOccupier.Occupy(tr)
	if err != null:
		print(err)
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
	var ref_vec = Vector2(0, -900)
	var x = game.World().ToPixel(scalar.Sub(game.World().FromPixel(castPosX), PositionX()))
	var y = game.World().ToPixel(scalar.Sub(game.World().FromPixel(castPosY), PositionY()))
	var vec = Vector2(x, y).rotated($Rotatable.rotation)
	var angle = ref_vec.angle_to(vec)
	var scale = vec.length()/ref_vec.length()
	var old_anim = $AnimationPlayer.get_animation("skill-ref")
	var new_anim = $AnimationPlayer.get_animation("skill")
	var tracks = ["Rotatable/Body:position", "Rotatable/DummyTurret:position"]
	for track in tracks:
		var track_idx = old_anim.find_track(track)
		var key_count = old_anim.track_get_key_count(track_idx)
		for i in range(key_count):
			var v = old_anim.track_get_key_value(track_idx, i)
			new_anim.track_set_key_value(track_idx, i, v.rotated(angle) * scale)

func spawn():
	var name = stat.cards[Skill()]["unit"]
	var id = game.AddUnit(name, level, castPosX, castPosY, player)
	var tr = TileOccupier.Occupied()
	TileOccupier.Release()
	var occupier = game.FindUnit(id).get("TileOccupier")
	if occupier != null:
		var err = occupier.Occupy(tr)
		if err != null:
			print(err)

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
	b.global_position = $Rotatable/Body/Main/Gun/ShootingPoint.global_position