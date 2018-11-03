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
var castTile = preload("res://game/script/tileoccupier.gd")
var prevDeathToll = 0

func _ready():
	var dup = $AnimationPlayer.get_animation("skill").duplicate()
	$AnimationPlayer.rename_animation("skill", "skill-ref")
	$AnimationPlayer.add_animation("skill", dup)

func Init(id, level, posX, posY, game, player):
	New(id, "tombstone", player.Team(), level, posX, posY, game)
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
	castTile = castTile.new(game)
	initPosX = PositionX()
	initPosY = PositionY()
	var offsetX = scalar.Mul(game.Map().TileWidth(), scalar.FromInt(stat.HoverKnightTileOffsetX))
	minPosX = scalar.Sub(initPosX, offsetX)
	maxPosX = scalar.Add(initPosX, offsetX)

func TakeDamage(amount, attacker):
	var initHp = initialHp()
	var underHalf = initHp / 2 > hp
	.TakeDamage(amount, attacker)
	if not underHalf and initHp / 2 > hp:
		player.OnKnightHalfDamaged(self)
	if IsDead():
		player.OnKnightDead(self)

func Destroy():
	.Destroy()
	TileOccupier.Release()
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
	var atkrange = stat.units[name_]["attackrange"]
	var divider = 1
	var ratios = player.StatRatios("attackrangeratio")
	for i in range(len(ratios)):
		atkrange *= ratios[i]
		divider *= 100
	atkrange /= divider
	return game.World().FromPixel(atkrange)

func Update():
	if isLeader:
		var deathToll = game.DeathToll(Team())
		if deathToll != prevDeathToll and deathToll % Skill()["perdeaths"] == 0:
			prevDeathToll = deathToll
			spawn(Skill())
	if freeze > 0:
		attack = 0
		targetId = 0
		freeze -= 1
		return
	if cast > 0:
		if cast == preCastDelay() + 1:
			spawn(Skill())
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
	for pos in ["L", "R", "C"]:
		var n = get_node("Rotatable/Main/Body/Front/ShotPoint%s" % pos)
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
	return stat.units[name_]["skill"][key]

func CastSkill(posX, posY):
	if cast > 0:
		return false
	var name = Skill()["unit"]
	var nx = stat.units[name]["tilenumx"]
	var ny = stat.units[name]["tilenumy"]
	var tile = game.TileFromPos(posX, posY)
	var tr = castTile.GetRect(tile[0], tile[1], nx, ny)
	var err = castTile.Occupy(tr)
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
	var ref_vec = Vector2(0, -800) * $Rotatable.scale
	var x = game.World().ToPixel(scalar.Sub(game.World().FromPixel(castPosX), PositionX()))
	var y = game.World().ToPixel(scalar.Sub(game.World().FromPixel(castPosY), PositionY()))
	var vec = Vector2(x, y).rotated($Rotatable.rotation)
	if game.team_swapped:
		vec = vec.rotated(PI)
	var angle = ref_vec.angle_to(vec)
	var scale = vec.length()/ref_vec.length()
	var old_anim = $AnimationPlayer.get_animation("skill-ref")
	var new_anim = $AnimationPlayer.get_animation("skill")
	var tracks = ["Rotatable/Main:position"]
	for track in tracks:
		var track_idx = old_anim.find_track(track)
		var key_count = old_anim.track_get_key_count(track_idx)
		for i in range(key_count):
			var v = old_anim.track_get_key_value(track_idx, i)
			new_anim.track_set_key_value(track_idx, i, v.rotated(angle) * scale)

func spawn(data):
	var name = data["unit"]
	if name == "barrack":
		var unit = game.AddUnit(name, level, castPosX, castPosY, player)
		var tr = castTile.Occupied()
		castTile.Release()
		var occupier = unit.get("TileOccupier")
		if occupier != null:
			var err = occupier.Occupy(tr)
			if err != null:
				print(err)
	if name == "footman":
		var deadPosX = game.LastDeadPosX(Team())
		var offsetX = data["offsetX"]
		if scalar.Div(game.Map().Width(), scalar.Two) > deadPosX:
			offsetX *= -1
		var posX = game.World().ToPixel(initPosX) + offsetX
		var posY = game.World().ToPixel(initPosY)
		game.AddUnit(name, level, posX, posY, player)

func target():
	return game.FindUnit(targetId)

func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()
