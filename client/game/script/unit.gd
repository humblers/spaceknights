extends Node2D

const Z_INDEX = {
	"Normal": 0,
	"Ether": 1,
	"Bullet": 2,
	"Skill": 3,
	"Casting": 4,
}

const DAMAGE_FORWARD_DURATION = 0.2
const DAMAGE_BACKWARD_DURATION = 0.3

var id
var name_
var team
var level
var hp
var game
var body
var slowUntil = 0
var freeze = 0

var node_hp
var shade_nodes=[]
var custom_shader = preload("res://game/script/custom_shader.gd")
var shader_material = preload("res://game/unit/shader_material.tres")
var damages = {}
var client_team
var side	# knight position: Left, Center, or Right 

func InitDummy(posX, posY, game, player, enable_shade, initial_angle=0):
	self.team = player.team
	self.game = game
	if game.team_swapped:
		posX = game.FlipX(posX)
		posY = game.FlipY(posY)
	position = Vector2(posX, posY)
	init_rotation(initial_angle)
	init_shade(enable_shade)

func init_shade(enable):
	shade_nodes = custom_shader.get_shade_nodes(self)
	for n in shade_nodes:
		custom_shader.init(n, enable)
	if not enable:
		shade_nodes = []

func _process(delta):
	for n in shade_nodes:
		custom_shader.shade(n, game.MAIN_LIGHT_ANGLE)
	show_damage(delta)

func show_damage(elapsed):
	if material == null:
		return
	var max_value = 0
	for step in damages.keys():
		damages[step] += elapsed
		var t = damages[step]
		if t > DAMAGE_FORWARD_DURATION + DAMAGE_BACKWARD_DURATION:
			damages.erase(step)
			continue
		var value = t / DAMAGE_FORWARD_DURATION
		if t > DAMAGE_FORWARD_DURATION:
			value = 1 - (t - DAMAGE_FORWARD_DURATION) / DAMAGE_BACKWARD_DURATION
		if value > max_value:
			max_value = value
	material.set_shader_param("damage_ratio", max_value)

func Init(id, name, team, level, posX, posY, game):
	self.id = id
	self.name_ = name
	self.team = team
	self.level = level
	self.game = game
	var w = game.World()
	hp = initialHp()
	body = w.AddCircle(
		mass(),
		radius(),
		w.FromPixel(posX),
		w.FromPixel(posY)
	)
	setLayer(initialLayer())
	
	# client only
	body.node = self
	set_hp()
	client_team = team
	if game.team_swapped:
		posX = game.FlipX(posX)
		posY = game.FlipY(posY)
		client_team = "Red" if team == "Blue" else "Blue"
	position = Vector2(posX, posY)
	init_rotation()
	init_shade(true)
	material = shader_material.duplicate()
	material.set_shader_param("is_blue", true if team == "Blue" else false)
	return self
	
func setLayer(l):
	if l == "Casting":
		body.Simulate(false)
	else:
		body.Simulate(true)
	body.SetLayer(l)
	z_index = Z_INDEX[l]
	
func init_rotation(initial_angle=0):
	if Team() == "Red":
		$Rotatable.rotation = PI
	else:
		$Rotatable.rotation = 0
	if game.team_swapped:
		$Rotatable.rotation += PI
	$Rotatable.rotation -= initial_angle

func look_at_pos(x, y):
	var px = game.World().ToPixel(x)
	var py = game.World().ToPixel(y)
	if game.team_swapped:
		px = game.FlipX(px)
		py = game.FlipY(py)
	var dir = Vector2(px, py) - position
	$Rotatable.rotation = PI/2 + dir.angle()	# unit initial angle = -90

func set_hp():
	var color = Team()
	if game.team_swapped:
		color = "Blue" if Team() == "Red" else "Red"
	node_hp = $Hp.get_node(color)
	node_hp.max_value = hp
	node_hp.value = hp

func Id():
	return id

func Name():
	return name_

func Team():
	return team

func Type():
	return stat.units[name_]["type"]

func Layer():
	return body.Layer()

func IsDead():
	return hp <= 0

func TakeDamage(amount, attackType):
	if Layer() != "Normal":
		return
	hp -= amount
	node_hp.value = hp
	node_hp.visible = true
	if attackType != "Self":
		damages[game.step] = 0	

func Destroy():
	$Sound/sound_death.play()
	game.World().RemoveBody(body)

func MakeSlow(duration):
	slowUntil = game.Step() + duration

func Freeze(duration):
	if Layer() == "Casting":
		return
	if freeze < duration:
		freeze = duration
	$AnimationPlayer.stop()
	
func PositionX():
	return body.PositionX()

func PositionY():
	return body.PositionY()

func SetPosition(x, y):
	body.SetPosition(x, y)

func Radius():
	return body.Radius()

func SetVelocity(x, y):
	body.SetVelocity(x, y)

func AddForce(x, y):
	body.AddForce(x, y)

func Simulate(on):
	body.Simulate(on)

func SetAsLeader():
	print("not implemented")

func Skill():
	print("not implemented")

func CastSkill(posX, posY):
	print("not implemented")

func initialLayer():
	return stat.units[name_]["layer"]

func mass():
	var m = stat.units[name_]["mass"]
	return scalar.FromInt(m)

func radius():
	var r = stat.units[name_]["radius"]
	return game.World().FromPixel(r)

func initialHp():
	var v = stat.units[name_]["hp"]
	var t = typeof(v)
	match t:
		TYPE_INT:
			return v
		TYPE_ARRAY:
			return v[level]
		_:
			print("invalid hp type")

func initialShield():
	var v = stat.units[name_]["shield"]
	var t = typeof(v)
	if t == TYPE_INT:
		return v
	if t == TYPE_ARRAY:
		return v[level]
	print("invalid shield type")

func sight():
	var s = stat.units[name_]["sight"]
	return game.World().FromPixel(s)

func speed():
	var s = stat.units[name_]["speed"]
	if slowUntil >= game.Step():
		s = s * stat.SlowPercent / 100
	return game.World().FromPixel(s)

func targetTypes():
	return stat.units[name_]["targettypes"]

func targetLayers():
	return stat.units[name_]["targetlayers"]

func attackDamage():
	var v = stat.units[name_]["attackdamage"]
	var t = typeof(v)
	if t == TYPE_INT:
		return v
	if t == TYPE_ARRAY:
		return v[level]
	print("invalid attack damage type")

func attackRange():
	var r = stat.units[name_]["attackrange"]
	return game.World().FromPixel(r)

func attackInterval():
	var i = stat.units[name_]["attackinterval"]
	if slowUntil >= game.Step():
		i = i * 100 / stat.SlowPercent
	return i

func preAttackDelay():
	return stat.units[name_]["preattackdelay"]
func bulletLifeTime():
	return stat.units[name_]["bulletlifetime"]
func canSee(unit):
	if unit.Type() == "Knight":
		return true
	var r = sight() + Radius() + unit.Radius()
	return squaredDistanceTo(unit) < scalar.Mul(r, r)

func withinRange(unit):
	var r = attackRange() + Radius() + unit.Radius()
	return squaredDistanceTo(unit) < scalar.Mul(r, r)

func findTarget():
	var nearest = null
	var distance = 0
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		if not targetTypes().has(u.Type()):
			continue
		if not targetLayers().has(u.Layer()):
			continue
		if not canSee(u):
			continue
		var d = squaredDistanceTo(u)
		if nearest == null or d < distance:
			nearest = u
			distance = d
	return nearest

func squaredDistanceTo(unit):
	var x = scalar.Sub(PositionX(), unit.PositionX())
	var y = scalar.Sub(PositionY(), unit.PositionY())
	return vector.LengthSquared(x, y)

func moveTo(posX, posY):
	var x = scalar.Sub(posX, PositionX())
	var y = scalar.Sub(posY, PositionY())
	var v = vector.Truncated(x, y, speed())
	SetVelocity(v[0], v[1])
