#extends "res://game/script/unit.gd"
extends Node2D

const Z_INDEX = {
	"Normal": 0,
	"Ether": 1,
	"Casting": 2,
}

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
var retargeting = false

var skillReady = false

var color = "Blue"
var id
var name_
var team
var level
var hp
var game
var body
var tiles
var slowUntil = 0
var freeze = 0
var prev_desired_pos_x = 0
var prev_desired_pos_y = 0
var moving = false
var side = "Center"

var shader_material = preload("res://material/light_and_damage.tres")

func New(id, name, team, level, posX, posY, game):
	self.id = id
	self.name_ = name
	self.team = team
	self.level = level
	self.game = game
	var w = game.World()
	hp = InitialHp()
	body = w.AddCircle(
		mass(),
		radius(),
		w.FromPixel(posX),
		w.FromPixel(posY)
	)
	setLayer(initialLayer())
	
	# client only
	body.node = self
	color = team
	if game.team_swapped:
		posX = game.FlipX(posX)
		posY = game.FlipY(posY)
		color = "Red" if team == "Blue" else "Blue"
	set_hp()
	setLevel()
	position = Vector2(posX, posY)
	material = shader_material.duplicate()
	material.set_shader_param("is_blue", true if team == "Blue" else false)
	var debug = preload("res://game/debug/debug.tscn").instance()
	debug.init(self, game)
	$AnimationPlayer.play("idle")
	add_child(debug)
	return self

func initialLayer():
	return data.units[name_]["layer"]

func setLevel():
	$Hp/HBoxContainer/Control/LevelLabel.text = "%d" % (level + 1)
	if color == "Red":
		$Hp/HBoxContainer/Control.visible = true

func setLayer(l):
	if l == data.Casting:
		body.Simulate(false)
	else:
		body.Simulate(true)
	body.SetLayer(l)
	z_index = Z_INDEX[l]
	
func mass():
	var m = data.units[name_]["mass"]
	return scalar.FromInt(m)
	
func radius():
	var r = data.units[name_]["radius"]
	return game.World().FromPixel(r)

func InitialHp():
	var v = data.units[name_]["hp"]
	var t = typeof(v)
	match t:
		TYPE_INT:
			return v
		TYPE_ARRAY:
			return v[level]
		_:
			print("invalid hp type")
			
func IsDead():
	return hp <= 0

func sight():
	var s = data.units[name_]["sight"]
	return game.World().FromPixel(s)

func speed():
	var s = data.units[name_]["speed"]
	if slowUntil >= game.Step():
		s = s * data.SlowPercent / 100
	return game.World().FromPixel(s)


#func Init(id, level, posX, posY, game, player):
#	New(id, "valkyrie", player.Team(), level, posX, posY, game)
#	self.player = player
#	var tile = game.TileFromPos(posX, posY)
#	var tr = game.NewTileRect(
#		tile[0],
#		tile[1],
#		player.KNIGHT_TILE_NUM_X,
#		player.KNIGHT_TILE_NUM_Y
#	)
#	.Occupy(tr)
#	initPosX = PositionX()
#	initPosY = PositionY()
#	var offsetX = scalar.Mul(game.Map().TileWidth(), scalar.FromInt(data.HoverKnightTileOffsetX))
#	minPosX = scalar.Sub(initPosX, offsetX)
#	maxPosX = scalar.Add(initPosX, offsetX)

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
#		damage += amplifies[i] * cnt * attackInterval() / data.StepPerSec
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
	
	handleAttack()
	
func handleAttack():
#	var modulo = attack % attackInterval()
#	if modulo == 0:
#		$AnimationPlayer.play("attack")
#	if modulo == preAttackDelay():
#		var t = target()
#		if t != null and withinRange(t):
#			fire()
#		else:
#			retargeting = true
#			return
#	retargeting = attack > 0 and modulo == 0
#	attack += 1
	pass



func castDuration():
	return Skill()["castduration"]

func preCastDelay():
	return Skill()["precastdelay"]

func freezeDuration():
	return Skill()["freezeduration"]

func SetAsLeader():
	isLeader = true
	
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
	$AnimationPlayer.play("skill")
	setLayer(data.Casting)

func threatMissile():
	var skill = Skill()
	var unit = skill["unit"]
	var count = skill["count"]
	var offsetX = skill["offsetX"]
	var offsetY = skill["offsetY"]
	var posX = game.World().ToPixel(initPosX)
	var posY = game.World().ToPixel(initPosY)
	for i in count:
		game.AddUnit(unit, level, posX + offsetX[i], posY + offsetY[i], player)

func target():
	return game.FindUnit(targetId)
	
func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()

func fire():
#	var b = $ResourcePreloader.get_resource("missile").instance()
	var b = $ResourcePreloader.get_resource("bullet").instance()
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
	b.rotation = $Rotatable.rotation
	b.global_position = $Rotatable/Body/Missile.global_position
