extends Node2D

const Z_INDEX = {
	"Normal": 0,
	"Ether": 1,
	"Casting": 2,
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
var tiles
var slowUntil = 0
var freeze = 0
var prev_desired_pos_x = 0
var prev_desired_pos_y = 0
var moving = false

var shader_material = preload("res://material/light_and_damage.tres")
var damages = {}
var color
var side	# knight position: Left, Center, or Right 

func State():
	return {
		"id": id,
		"name": name_,
		"team": team,
		"level": level,
		"hp": hp,
		"body": body.State(),
		"slowUntil": slowUntil,
		"freeze": freeze,
		"prev_desired_pos": {"X": prev_desired_pos_x, "Y": prev_desired_pos_y},
		"moving": moving
	}
	
func Hash():
	return djb2.Combine([
		djb2.HashInt(id),
		djb2.HashString(name_),
		djb2.HashString(team),
		djb2.HashInt(level),
		djb2.HashInt(hp),
		body.Hash(),
		djb2.HashInt(slowUntil),
		djb2.HashInt(freeze),
		vector.Hash(prev_desired_pos_x, prev_desired_pos_y),
		djb2.HashBool(moving)
	])
	
func InitDummy(posX, posY, game, player, initial_angle=0):
	self.team = player.team
	self.game = game
	if game.team_swapped:
		posX = game.FlipX(posX)
		posY = game.FlipY(posY)
	position = Vector2(posX, posY)
	init_rotation(initial_angle)
	$AnimationPlayer.play("idle")

func _process(delta):
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

func CanCastSkill():
	assert(false)
	
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
	init_rotation()
	material = shader_material.duplicate()
	material.set_shader_param("is_blue", true if team == "Blue" else false)
	var debug = preload("res://game/debug/debug.tscn").instance()
	debug.init(self, game)
	$AnimationPlayer.play("idle")
	add_child(debug)
	return self

# debug circle radius in pixels
# TODO: use the function in logic routine
func _radius():
	return data.units[name_].get("radius", 0)

func _range():
	return data.units[name_].get("attackrange", 0)
	
func _sight():
	return data.units[name_].get("sight", 0)
	
func setLayer(l):
	if l == data.Casting:
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

func set_rot(vel_x, vel_y):
	$Rotatable.rotation = PI/2 + Vector2(vel_x, vel_y).angle()
	if game.team_swapped:
		$Rotatable.rotation += PI
	
func set_hp():
	var node_hp = get_node("Hp/HBoxContainer/VBoxContainer/%s" % color)
	node_hp.max_value = hp
	node_hp.value = hp

func setLevel():
	$Hp/HBoxContainer/Control/LevelLabel.text = "%d" % (level + 1)
	if color == "Red":
		$Hp/HBoxContainer/Control.visible = true

func Id():
	return id

func Name():
	return name_

func Team():
	return team

func Type():
	return data.units[name_]["type"]

func Layer():
	return body.Layer()

func IsDead():
	return hp <= 0

func Hp():
	return hp

func SetHp(hp):
	self.hp = hp
	set_hp()
	
func TakeDamage(amount, damageType, attacker):
	if Layer() != data.Normal:
		return
	hp -= amount
	var node_hp = get_node("Hp/HBoxContainer/VBoxContainer/%s" % color)
	node_hp.value = hp
	node_hp.visible = true
	$Hp/HBoxContainer/Control.visible = true

	# client only
	if damageType == data.Decay:
		return
	damages[game.step] = 0
	$HitEffect.hit(damageType)

func Occupy(tr):
	game.Occupy(tr, id)
	tiles = tr

func Release():
	game.Release(tiles, id)
	tiles = null
	
func Destroy():
	game.World().RemoveBody(body)
	$Hp.visible = false

func MakeSlow(duration):
	if duration <= 0:
		return
	slowUntil = game.Step() + duration

func Freeze(duration):
	if Layer() == data.Casting:
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
	return data.units[name_]["layer"]

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

func initialShield():
	var v = data.units[name_]["shield"]
	var t = typeof(v)
	if t == TYPE_INT:
		return v
	if t == TYPE_ARRAY:
		return v[level]
	print("invalid shield type")

func sight():
	var s = data.units[name_]["sight"]
	return game.World().FromPixel(s)

func speed():
	var s = data.units[name_]["speed"]
	if slowUntil >= game.Step():
		s = s * data.SlowPercent / 100
	return game.World().FromPixel(s)

func targetTypes():
	return data.units[name_]["targettypes"]

func targetLayers():
	return data.units[name_]["targetlayers"]

func damageType():
	return data.units[name_]["damagetype"]

func attackDamage():
	var v = data.units[name_]["attackdamage"]
	var t = typeof(v)
	if t == TYPE_INT:
		return v
	if t == TYPE_ARRAY:
		return v[level]
	print("invalid attack damage type")

func attackRange():
	var r = data.units[name_]["attackrange"]
	return game.World().FromPixel(r)

func attackInterval():
	var i = data.units[name_]["attackinterval"]
	if slowUntil >= game.Step():
		i = i * 100 / data.SlowPercent
	return i

func preAttackDelay():
	return data.units[name_]["preattackdelay"]
func bulletLifeTime():
	return data.units[name_]["bulletlifetime"]
func canSee(unit):
	if unit.Type() == data.Knight:
		return true
	var r = sight() + unit.Radius()
	return squaredDistanceTo(unit) < scalar.Mul(r, r)

func withinRange(unit):
	var r = attackRange() + unit.Radius()
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

func moveToPos(posX, posY):
	assert(mass() == 0)
	var dx = scalar.Sub(posX, PositionX())
	var dy = scalar.Sub(posY, PositionY())
	var v = vector.Truncated(dx, dy, speed())
	var x = scalar.Add(PositionX(), scalar.Mul(v[0], game.world.dt))
	var y = scalar.Add(PositionY(), scalar.Mul(v[1], game.world.dt))
	SetPosition(x, y)

func moveTo(unit, play_anim = true):
	var x
	var y
	if Layer() == data.Ether:
		x = scalar.Sub(unit.PositionX(), PositionX())
		y = scalar.Sub(unit.PositionY(), PositionY())
	else:
		var corner = game.Map().FindNextCornerInPath(
			PositionX(), PositionY(),
			unit.PositionX(), unit.PositionY(),
			Radius())
		x = scalar.Sub(corner[0], PositionX())
		y = scalar.Sub(corner[1], PositionY())
	var direction = vector.Normalized(x, y)
	var speed = speed()
	var desired_vel_x = scalar.Mul(direction[0], speed)
	var desired_vel_y = scalar.Mul(direction[1], speed)
	var desired_pos_x = scalar.Add(PositionX(), scalar.Mul(desired_vel_x, game.world.dt))
	var desired_pos_y = scalar.Add(PositionY(), scalar.Mul(desired_vel_y, game.world.dt))
	if body.colliding and moving:
		var diff_x = scalar.Sub(prev_desired_pos_x, body.pos_x)
		var diff_y = scalar.Sub(prev_desired_pos_y, body.pos_y)
		var l = vector.Length(diff_x, diff_y)
		var adjust_ratio = scalar.Clamp(scalar.Div(l, scalar.Mul(speed, game.world.dt)), 0, scalar.One)
		var to_x = -desired_vel_y if diff_x < 0 else desired_vel_y
		var to_y = desired_vel_x if diff_x < 0 else -desired_vel_x
		desired_vel_x = scalar.Add(desired_vel_x, scalar.Mul(to_x, adjust_ratio))
		desired_vel_y = scalar.Add(desired_vel_y, scalar.Mul(to_y, adjust_ratio))
		var truncated = vector.Truncated(desired_vel_x, desired_vel_y, speed)
		desired_vel_x = truncated[0]
		desired_vel_y = truncated[1]
		desired_pos_x = scalar.Add(PositionX(), scalar.Mul(desired_vel_x, game.world.dt))
		desired_pos_y = scalar.Add(PositionY(), scalar.Mul(desired_vel_y, game.world.dt))
	SetPosition(desired_pos_x, desired_pos_y)
	prev_desired_pos_x = desired_pos_x
	prev_desired_pos_y = desired_pos_y
	moving = true
	
	# client only
	set_rot(desired_vel_x, desired_vel_y)
	if play_anim:
		if $AnimationPlayer.assigned_animation != "move":
			$AnimationPlayer.play("move")
		if $Sound/Move.playing == false:
			$Sound/Move.play()

func Update():
	moving = false
	SetVelocity(0, 0)

func SetSide(side):
	self.side = side