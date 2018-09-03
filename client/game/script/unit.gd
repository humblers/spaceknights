extends Node2D

const Z_INDEX = {
	"Normal": 0,
	"Ether": 1,
	"Bullet": 2,
	"Skill": 3,
	"Casting": 4,
}

const DAMAGED_FOWARD_DURATION = 0.2
const DAMAGED_BACKWARD_DURATION = 0.3
const DAMAGED_TOTAL_DURATION = DAMAGED_FOWARD_DURATION + DAMAGED_BACKWARD_DURATION

var id
var name_
var team
var level
var hp
var game
var body

var node_hp
var shade_nodes=[]
var shader = preload("res://game/script/shader.gd")

var damaged_steps = {}
var damaged_color

func InitDummy(posX, posY, game, player, enable_shade):
	self.team = player.team
	self.game = game
	if game.team_swapped:
		posX = game.FlipX(posX)
		posY = game.FlipY(posY)
	position = Vector2(posX, posY)
	init_rotation()
	init_shade(enable_shade)

func init_shade(enable):
	shade_nodes = shader.get_shade_nodes(self)
	for n in shade_nodes:
		shader.init(n, enable)
	if not enable:
		shade_nodes = []

func _process(delta):
	for n in shade_nodes:
		shader.shade(n, game.MAIN_LIGHT_ANGLE)
	for step in damaged_steps.keys():
		damaged_steps[step] += delta
		var elapsed = damaged_steps[step]
		if elapsed > DAMAGED_TOTAL_DURATION:
			damaged_steps.erase(step)
			continue
		var color = Color(0, 0, 0, 1)
		var colors = [color, damaged_color]
		var weight = elapsed / DAMAGED_FOWARD_DURATION
		if elapsed > DAMAGED_FOWARD_DURATION:
			colors.invert()
			weight = (elapsed - DAMAGED_FOWARD_DURATION) / DAMAGED_BACKWARD_DURATION
		var interpolated = colors[0].linear_interpolate(colors[1], weight)
		if color.r < interpolated.r:
			color = interpolated
		material.set_shader_param("damaged_color", color)

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
	init_shade(true)
	init_material()
	return self
	
func setLayer(l):
	if l == "Casting":
		body.Simulate(false)
	else:
		body.Simulate(true)
	body.SetLayer(l)
	z_index = Z_INDEX[l]
	
func init_rotation():
	if Team() == "Red":
		$Rotatable.global_rotation = PI
	else:
		$Rotatable.global_rotation = 0
	if game.team_swapped:
		$Rotatable.rotation += PI

func init_material():
	material = resource.MATERIAL[Team().to_lower()].duplicate()
	damaged_color = material.get_shader_param("damaged_color")
	material.set_shader_param("damaged_color", Color(0, 0, 0, 1))

func look_at(x, y):
	var px = game.World().ToPixel(x)
	var py = game.World().ToPixel(y)
	if game.team_swapped:
		px = game.FlipX(px)
		py = game.FlipY(py)
	var dir = Vector2(px, py) - position
	$Rotatable.global_rotation = PI/2 + dir.angle()	# unit initial angle = -90

func set_hp():
	var color = Team()
	if game.team_swapped:
		color = "Blue" if Team() == "Red" else "Red"
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
	if attackType != "Self":
		# damaged_color blending with code
		if not damaged_steps.has(game.step):
			damaged_steps[game.step] = 0
#	    # damaged_color blending with Tween node
#		var initial_color = material.get_shader_param("damaged_color")
#		$Tween.interpolate_method(self, "set_damaged_color", initial_color, damaged_color, FOWARD_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
#		$Tween.interpolate_method(self, "set_damaged_color", damaged_color, Color(0, 0, 0, 1), BACKWARD_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN, FOWARD_DURATION)
#		$Tween.start()
#
#func set_damaged_color(color):
#	material.set_shader_param("damaged_color", color)

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
