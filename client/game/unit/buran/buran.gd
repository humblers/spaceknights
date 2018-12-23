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
var castTiles

func _ready():
	var dup = $AnimationPlayer.get_animation("skill").duplicate()
	$AnimationPlayer.rename_animation("skill", "skill-ref")
	$AnimationPlayer.add_animation("skill", dup)

func Init(id, level, posX, posY, game, player):
	New(id, "buran", player.Team(), level, posX, posY, game)
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

func TakeDamage(amount, attacker):
	var initHp = InitialHp()
	var underHalf = initHp / 2 > hp
	.TakeDamage(amount, attacker)
	if not underHalf and initHp / 2 > hp:
		player.OnKnightHalfDamaged(self)
	if IsDead():
		player.OnKnightDead(self)

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
	return damage / divider

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
		if target() == null:
			setTarget(findTarget())
			attack = 0
		var t = target()
		if t != null and canSee(t):
			var posX = scalar.Clamp(t.PositionX(), minPosX, maxPosX)
			moveToPos(posX, PositionY())
			if withinRange(t):
				if attack % attackInterval() == 0:
					t.TakeDamage(attackDamage(), self)
					var duration = 0
					for d in player.StatRatios("slowduration"):
						duration += d
					t.MakeSlow(duration)
				attack += 1
			else:
				attack = 0
				$Sound/Attack.stop()
		else:
			moveToPos(initPosX, initPosY)
			attack = 0
			$Sound/Attack.stop()
		
	# client only
	if targetId <= 0 and cast <= 0:
		$AnimationPlayer.play("idle")
	show_laser(attack > 0)

func show_laser(enable):
	for pos in ["L1", "R1", "L2", "R2"]:
		var n = get_node("Rotatable/Body/Weapon/Laser%s" % pos)
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
			if $Sound/Attack.playing == false:
				$Sound/Attack.play()

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