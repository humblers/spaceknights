extends Node2D

var connected = false
var cfg = config.GAME

const PLAY_TIME = 60000		# milliseconds
const STEP_INTERVAL = 100	# milliseconds
const STEP_PER_SEC = 10
const KNIGHT_INITIAL_STEP = STEP_PER_SEC * 5

const FRAME_PER_STEP = Engine.iterations_per_second / STEP_PER_SEC
const PACKET_WINDOW = 5

export(float, 0, 360) var MAIN_LIGHT_ANGLE = 0

# parameters for physics world
var params = {
	"scale": scalar.Div(scalar.One, scalar.FromInt(10)),
	"dt": scalar.Div(scalar.One, scalar.FromInt(STEP_PER_SEC)),
	"gravity_y": 0,
	"restitution": scalar.Div(scalar.One, scalar.FromInt(10)),
}

# current simulation step
var step = 0

var world = resource.WORLD.new(params)
var map

var units = {}
var occupiedTiles = {}
var deathToll = {}
var lastDeadPosX = {}
var unitCounter = 0
var players = {}
var bullets = []
var actions = {}

# client physics frame
var frame = 0

# for stop signal
var to_stop = false

# elapsed sec since last logic update
var elapsed = 0

var team_swapped = false

onready var camera = $Camera2D

func _ready():
	if connected:
		tcp.connect("disconnected", self, "request_stop")
	else:
		$Camera2D.zoom = Vector2(1.1, 1.1)
		$Camera2D.position.y -= 50
		$Players/Red.show()
	set_process(true)
	set_physics_process(true)

	self.deathToll = {"Blue":0, "Red":0}
	self.lastDeadPosX = {"Blue":0, "Red":0}

	map = resource.MAP[cfg.MapName].new(world)
	team_swapped = user.ShouldSwapTeam(cfg)
	for p in cfg.Players:
		var team = p.Team
		if team_swapped:
			team = "Blue" if p.Team == "Red" else "Red"
		var n = $Players.get_node(team)
		n.Init(p, self)
		players[p.Id] = n
		get_node("Map/MotherShips/%s" % team).init(self, n, p.Knights)
	CreateMapObstacles()

func over():
	return step >= PLAY_TIME/STEP_INTERVAL

func request_stop():
	to_stop = true

func stop():
	set_process(false)
	set_physics_process(false)

func CreateMapObstacles():
	for o in map.GetObstacles():
		var width = world.ToPixel(map.AreaWidth(o))
		var height = world.ToPixel(map.AreaHeight(o))
		var x = world.ToPixel(map.AreaPosX(o))
		var y = world.ToPixel(map.AreaPosY(o))
		var b = world.AddBox(
			scalar.FromInt(0),
			world.FromPixel(width),
			world.FromPixel(height),
			world.FromPixel(x),
			world.FromPixel(y)
		)
		b.SetLayer("Normal")

func _process(delta):
	elapsed += delta
	var t = clamp(elapsed * STEP_PER_SEC, 0, 1)
	for b in world.bodies:
		if b.node != null and not b.no_physics:
			var prev = Vector2(
				world.ToPixel(b.prev_pos_x),
				world.ToPixel(b.prev_pos_y)
			)
			var curr = Vector2(
				world.ToPixel(b.pos_x),
				world.ToPixel(b.pos_y)
			)
			if team_swapped:
				prev.x = FlipX(prev.x)
				prev.y = FlipY(prev.y)
				curr.x = FlipX(curr.x)
				curr.y = FlipY(curr.y)
			b.node.position = prev.linear_interpolate(curr, t)

func _physics_process(delta):
	if frame % FRAME_PER_STEP == 0:
		if connected:
			var iterations = 1
			var n = tcp.received.size()
			if n <= 0:
				if to_stop:
					stop()
					return
				print("not enough packets")
				iterations = 0
			if n > PACKET_WINDOW:
				print("too many packets %s" % [n])
				iterations = min(10, n)
			for i in range(iterations):
				var state = parse_json(tcp.received.pop_front())
				update(state)
		else:
			var state = {"Actions": null}
			if actions.has(step):
				state["Actions"] = actions[step]
			update(state)
		$Map/MotherShips/Red.play(self)
		$Map/MotherShips/Blue.play(self)
	
	frame += 1

func update(state):
	if step == KNIGHT_INITIAL_STEP:
		for player in cfg.Players:
			players[player.Id].AddKnights(player.Knights)
	if state.Actions != null:
		for action in state.Actions:
			players[action.Id].Do(action)
	for id in players:
		players[id].Update()
	for id in units.keys():
		units[id].Update()
	for b in bullets:
		b.Update(self)
	removeDeadUnits()
	removeExpiredBullets()
	world.Step()
	
	# validate
	if connected:
		if step != state.Step:
			print("step mismatch: %s - %s" % [step, state.Step])
		var client_hash = world.Digest()
		var server_hash = state.Hash
		if client_hash != server_hash:
			print("desync detected(%s): %s - %s" % [step, client_hash, server_hash])

	step += 1
	elapsed = 0

func removeDeadUnits():
	for id in units.keys():
		var u = units[id]
		if u.IsDead():
			units.erase(id)
			if u.Type() != "Knight":
				deathToll[u.Team()] += 1
				lastDeadPosX[u.Team()] = u.PositionX()
			u.Destroy()

func removeExpiredBullets():
	var filtered = []
	for b in bullets:
		if b.IsExpired():
			b.Destroy()
		else:
			filtered.append(b)
	bullets = filtered

func AddUnit(name, level, posX, posY, player):
	unitCounter += 1
	var id = unitCounter
	var node = resource.UNIT[name].instance()
	node.Init(id, level, posX, posY, self, player)
	node.name = str(id)
	$Units.add_child(node)
	units[id] = node
	return id

func FindUnit(id):
	if units.has(id):
		return units[id]
	else:
		return null

func AddBullet(bullet):
	$Bullets.add_child(bullet)
	bullets.append(bullet)

func World():
	return world

func Map():
	return map

func UnitIds():
	return units.keys()

func OccupiedTiles():
	return occupiedTiles

func DeathToll(team):
	return deathToll[team]

func LastDeadPosX(team):
	return lastDeadPosX[team]

func FlipX(x):
	return world.ToPixel(map.Width()) - x

func FlipY(y):
	return world.ToPixel(map.Height()) - y

func TileFromPos(x, y):
	var tx = int(clamp(x / world.ToPixel(map.TileWidth()), 0, map.TileNumX() - 1))
	var ty = int(clamp(y / world.ToPixel(map.TileHeight()), 0, map.TileNumY() - 1))
	return [tx, ty]

func PosFromTile(x, y):
	if map.TileNumX() - 1 < x || x < 0:
		return [null, null, "invalid tile x: %d" % x]
	if map.TileNumY() - 1 < y || y < 0:
		return [null, null, "invalid tile y: %d" % y]
	var tw = world.ToPixel(map.TileWidth())
	var th = world.ToPixel(map.TileHeight())
	return [x*tw + tw/2, y*th + th/2, null]

static func intersect_tilerect(a, b):
	if a.t > b.b:
		return false
	if a.b < b.t:
		return false
	if a.l > b.r:
		return false
	if a.r < b.l:
		return false
	return true
