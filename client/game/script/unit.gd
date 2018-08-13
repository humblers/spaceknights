extends Node2D

const Z_INDEX = {
	"Normal": 0,
	"Ether": 1,
	"Bullet": 2,
	"Skill": 3,
	"Casting": 4,
	"NoPhysics": 5,
}

var id
var name_
var team
var level
var hp
var game
var body

var node_hp

func InitDummy(name, team, posX, posY, game):
	self.name_ = name
	self.team = team
	self.game = game
	if game.team_swapped:
		posX = game.FlipX(posX)
		posY = game.FlipY(posY)
	position = Vector2(posX, posY)
	init_rotation()
	return self

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
	if game.team_swapped:
		posX = game.FlipX(posX)
		posY = game.FlipY(posY)
	position = Vector2(posX, posY)
	init_rotation()
	return self

func setLayer(l):
	if l == "Casting":
		body.SetCollidable(false)
	else:
		body.SetCollidable(true)
	body.SetLayer(l)
	z_index = Z_INDEX[l]
	
func init_rotation():
	if team == "Red":
		$Rotatable.rotation = PI
	else:
		$Rotatable.rotation = 0
	if game.team_swapped:
		$Rotatable.rotation += PI
	
func look_at(x, y):
	var px = game.World().ToPixel(x)
	var py = game.World().ToPixel(y)
	if game.team_swapped:
		px = game.FlipX(px)
		py = game.FlipY(py)
	var dir = Vector2(px, py) - position
	$Rotatable.rotation = PI/2 + dir.angle()	# unit initial angle = -90

func set_hp():
	var color = team
	if game.team_swapped:
		color = "Blue" if team == "Red" else "Red"
	node_hp = $Hp.get_node(color)
	node_hp.show()
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

func Destroy():
	game.World().RemoveBody(body)
	
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

func SetCollidable(collidable):
	body.SetCollidable(collidable)

func Skill():
	return stat.units[name_]["skill"]

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
	if t == TYPE_INT:
		return v
	if t == TYPE_ARRAY:
		return v[level]
	print("invalid hp type")

func initialShield():
	return stat.units[name_]["shield"]

func sight():
	var s = stat.units[name_]["sight"]
	return game.World().FromPixel(s)

func speed():
	var s = stat.units[name_]["speed"]
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
	return stat.units[name_]["attackinterval"]

func preAttackDelay():
	return stat.units[name_]["preattackdelay"]
func bulletLifeTime():
	return stat.units[name_]["bulletlifetime"]
func transformDelay():
	return stat.units[name_]["transformdelay"]
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
		if u.Team() == team:
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