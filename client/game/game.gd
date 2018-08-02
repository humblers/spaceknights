extends Node2D

var cfg
#var cfg = {
#	"Id": "TEST",
#	"MapName": "Thanatos",
#	"Players": [
#		{
#			"Id": "Alice",
#			"Team": "Blue",
#			"Deck": [
#				{"Name": "fireball", "Level": 0},
#				{"Name": "archers", "Level": 0},
#				{"Name": "archers", "Level": 0},
#				{"Name": "fireball", "Level": 0},
#				{"Name": "archers", "Level": 0},
#				{"Name": "archers", "Level": 0},
#				{"Name": "fireball", "Level": 0},
#				{"Name": "archers", "Level": 0},
#			],
#			"Knights": [
#				{"Name": "legion", "Level": 0},
#				{"Name": "legion", "Level": 0},
#				{"Name": "legion", "Level": 0},
#			],
#		},
#		{
#			"Id": "Bob",
#			"Team": "Red",
##			"Deck": [
##				{"Name": "fireball", "Level": 0},
##				{"Name": "archers", "Level": 0},
##				{"Name": "archers", "Level": 0},
##				{"Name": "archers", "Level": 0},
##				{"Name": "archers", "Level": 0},
##				{"Name": "fireball", "Level": 0},
##				{"Name": "fireball", "Level": 0},
##				{"Name": "archers", "Level": 0},
##			],
#			"Knights": [
#				{"Name": "legion", "Level": 0},
#				{"Name": "legion", "Level": 0},
#				{"Name": "legion", "Level": 0},
#			],
#		}
#	],
#}

const PLAY_TIME = 180000		# milliseconds
const STEP_INTERVAL = 100	# milliseconds
const STEP_PER_SEC = 10

const FRAME_PER_STEP = Engine.iterations_per_second / STEP_PER_SEC
const PACKET_WINDOW = 5

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
var unitCounter = 0
var players = {}
var bullets = []

# client physics frame
var frame = 0

# for stop signal
var to_stop = false

# elapsed sec since last logic update
var elapsed = 0

var team_swapped = false

func _ready():
	tcp.connect("disconnected", self, "request_stop")
	set_process(true)
	set_physics_process(true)

	map = resource.MAP[cfg.MapName].new(world)
	team_swapped = user.ShouldSwapTeam(cfg)
	for p in cfg.Players:
		var team = p.Team
		if team_swapped:
			team = "Blue" if p.Team == "Red" else "Blue"
		var n = $Players.get_node(team)
		n.Init(p, self)
		players[p.Id] = n
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
		world.AddBox(
			scalar.FromInt(0),
			world.FromPixel(width),
			world.FromPixel(height),
			world.FromPixel(x),
			world.FromPixel(y)
		)

func _process(delta):
	elapsed += delta
	var t = clamp(elapsed * STEP_PER_SEC, 0, 1)
	for b in world.bodies:
		if b.node != null:
			var prev = Vector2(
				world.ToPixel(b.prev_pos_x),
				world.ToPixel(b.prev_pos_y)
			)
			var curr = Vector2(
				world.ToPixel(b.pos_x),
				world.ToPixel(b.pos_y)
			)
			b.node.position = prev.linear_interpolate(curr, t)

func _physics_process(delta):
	if frame % FRAME_PER_STEP == 0:
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
	
	frame += 1

func update(state):
	if state.Actions != null:
		for action in state.Actions:
			players[action.Id].Do(action)
	for id in players:
		players[id].Update()
	for id in units:
		units[id].Update()
	for b in bullets:
		b.Update(self)
	removeDeadUnits()
	removeExpiredBullets()
	world.Step()
	
	# validate
	if step != state.Step:
		print("step mismatch: %s - %s" % [step, state.Step])
	var client_hash = world.Digest()
	var server_hash = state.Hash
	if client_hash != server_hash:
		print("desync detected: %s - %s" % [client_hash, server_hash])

	step += 1
	elapsed = 0

func removeDeadUnits():
	for id in units.keys():
		var u = units[id]
		if u.IsDead():
			units.erase(id)
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
	var w = world.ToPixel(map.Width())
	var h = world.ToPixel(map.Height())
	if player.Team() == "Red":
		posX = w - posX
		posY = h - posY
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
