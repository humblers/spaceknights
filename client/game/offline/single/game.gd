extends Node2D

var connected = false
var cfg = config.GAME

const LEADER_SCORE = 3
const WING_SCORE = 1

const PACKET_WINDOW = 5

var frame_per_step = Engine.iterations_per_second / data.StepPerSec

# parameters for physics world
var params = {
	"scale": scalar.Div(scalar.One, scalar.FromInt(10)),
	"dt": scalar.Div(scalar.One, scalar.FromInt(data.StepPerSec)),
	"gravity_y": 0,
	"restitution": 0,
}

# current simulation step
var step = 0

onready var world = $Resource/Physics.get_resource("world").new(params)
onready var closing_scene = $UI/Hud/Closing
onready var bgm_anim = $BGM/AnimationPlayer
onready var boost_fx = $UI/EnergyBoost
onready var boost_ui = $UI/Hud/EnergyBoost
onready var opening_anim = $UI/Hud/Opening

var map

var units = {}
var deathToll = {}
var lastDeadPosX = {}
var unitCounter = 0
var players = {}
var bullets = []
var skills = []
var actions = {}
var occupied = []

# client physics frame
var frame = 0

# for stop signal
var to_stop = false

var initial_ff_finished = false

# elapsed sec since last logic update
var elapsed = 0

var team_swapped = false

onready var camera = $Camera2D

# debug options
var show_radius = false
var show_range = false
var show_sight = false
signal debug_option_changed

func _unhandled_key_input(ev):
	if ev.pressed:
		return
	match ev.scancode:
		KEY_F1:
			show_radius = not show_radius
		KEY_F2:
			show_range = not show_range
		KEY_F3:
			show_sight = not show_sight
	emit_signal("debug_option_changed")

func _ready():
	self.deathToll = {"Blue":0, "Red":0}
	self.lastDeadPosX = {"Blue":0, "Red":0}
	map = $Resource/Map.get_resource(cfg.MapName).new(world)
	initTiles()
	createMapObstacles()
	team_swapped = user.ShouldSwapTeam(cfg)
	for p in cfg.Players:
		var team = p.Team
		if team_swapped:
			team = "Blue" if p.Team == "Red" else "Red"
		var player = $Players.get_node(team)
		player.Init(p, self)
		players[p.Id] = player
		opening_anim.SetPlayerData(team, p.Id, player.leader, p.Rank)
		if team == "Blue":
			$UI/Hud/ID/RankIconBG/Text.text = "Imperial-Knight-%03d" % int(p.Id)
			$UI/Hud/ID/RankIconBG.texture = loading_screen.LoadResource("res://atlas/lobby/contents.sprites/rank/rank_icon_%d.tres" % user.Rank)
	event.emit_signal("GameInitialized", self)

	if connected:
		game_client.connect("disconnected", self, "request_stop")
		visible = false
		while not initial_ff_finished:
			yield(get_tree(), "idle_frame")
	opening_anim.Play()
	event.emit_signal("LoadSceneCompleted")
	visible = true
	
func initTiles():
	for i in map.TileNumX():
		occupied.append([])
		for j in map.TileNumY():
			occupied[i].append(0)

func FindPlayer(team):
	for id in players:
		var player = players[id]
		if team == player.Team():
			return player
	assert(false)

func Occupied(tr):
	for i in range(TileRectMinX(tr), TileRectMaxX(tr) + 1):
		for j in range(TileRectMinY(tr), TileRectMaxY(tr) + 1):
			if occupied[i][j] != 0:
				return true
	return false

func Occupy(tr, ownerId):
	for i in range(TileRectMinX(tr), TileRectMaxX(tr) + 1):
		for j in range(TileRectMinY(tr), TileRectMaxY(tr) + 1):
			assert(occupied[i][j] == 0)
			occupied[i][j] = ownerId

func Release(tr, ownerId):
	if tr == null:
		return
	for i in range(TileRectMinX(tr), TileRectMaxX(tr) + 1):
		for j in range(TileRectMinY(tr), TileRectMaxY(tr) + 1):
			assert(occupied[i][j] == ownerId)
			occupied[i][j] = 0
	
func Over():
	if step < data.PlayTime:
		if score("Blue") < LEADER_SCORE or score("Red") < LEADER_SCORE:
			return true
		else:
			return false
	elif step < data.PlayTime + data.OverTime:
		if score("Blue") != score("Red"):
			return true
		else:
			return false
	return true

func score(team):
	var score = 0
	for id in players:
		var p = players[id]
		if p.Team() == team:
			score += p.Score()
	return score

func request_stop():
	to_stop = true

func stop():
	set_process(false)
	set_physics_process(false)

func Step():
	return step

func createMapObstacles():
	for o in map.GetObstacles():
		var x = map.AreaPosX(o)
		var y = map.AreaPosY(o)
		var w = map.AreaWidth(o)
		var h = map.AreaHeight(o)
		var tw = map.TileWidth()
		var th = map.TileHeight()

		var b = world.AddBox(0, w, h, x, y)
		b.SetLayer(data.Normal)

		w = scalar.Mul(w, scalar.Two)
		h = scalar.Mul(h, scalar.Two)
		var tx = scalar.ToInt(scalar.Div(x, tw))
		var ty = scalar.ToInt(scalar.Div(y, th))
		var nx = scalar.ToInt(scalar.Div(w, tw))
		var ny = scalar.ToInt(scalar.Div(h, th))
		Occupy(NewTileRect(tx, ty, nx, ny), -1)

func _process(delta):
	elapsed += delta
	var t = clamp(elapsed * data.StepPerSec, 0, 1)
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
	if has_node("Debug"):
		get_node("Debug").update(self)

func _physics_process(delta):
	if frame % frame_per_step == 0:
		if Over():
			set_physics_process(false)
			bgm_anim.play("fade-out")
			closing_scene.Init(user.Rank, user.Medal, user.BattleChestOrder)
			var my_team = $Players/Blue.team
			var enemy_team = "Blue" if my_team == "Red" else "Red"
			var my_score = score(my_team)
			var enemy_score = score(enemy_team)
			if my_score > enemy_score:
				closing_scene.PlayWinAnim()
			elif my_score < enemy_score:
				closing_scene.PlayLoseAnim()
			else:
				closing_scene.PlayDrawAnim()
		else:
			if connected:
				var iterations = 1
				var n = game_client.received.size()
				if n > PACKET_WINDOW:
					print("too many packets %s" % [n])
					iterations = min(10, n)
				else:
					initial_ff_finished = true
					if n <= 0:
						if to_stop:
							stop()
							return
						print("not enough packets")
						iterations = 0
				for i in range(iterations):
					var state = static_func.cast_float_to_int(parse_json(game_client.received.pop_front()))
					Update(state)
			else:
				var state = {"Actions": null}
				if actions.has(step):
					state["Actions"] = actions[step]
				Update(state)
	
	frame += 1

func Hash():
	var hashes = [
		djb2.HashInt(step),
		djb2.HashInt(unitCounter),
		djb2.HashInt(deathToll["Blue"]),
		djb2.HashInt(deathToll["Red"]),
		world.Hash(),
		scalar.Hash(lastDeadPosX["Blue"]),
		scalar.Hash(lastDeadPosX["Red"]),
	]
	for id in units.keys():
		hashes.append(units[id].Hash())
	for b in bullets:
		hashes.append(b.Hash())
	for s in skills:
		hashes.append(s.Hash())
	for row in occupied:
		for i in row:
			hashes.append(djb2.HashInt(i))
	return djb2.Combine(hashes)

func State():
	var state = {
		"step": step,
		"unitCounter": unitCounter,
		"deathToll": deathToll,
		"world": world.State(),
		"lastDeadPosX": lastDeadPosX,
		"units": {},
		"bullets": [],
		"skills": [],
		"occupied": [],
	}
	for id in units:
		state["units"][id] = units[id].State()
	for b in bullets:
		state["bullets"].append(b.State())
	for s in skills:
		state["skills"].append(s.State())
	for row in occupied:
		var slice = []
		state["occupied"].append(slice)
		for i in row:
			slice.append(i)
	return state

func Update(state):
	if state.Actions != null:
		for action in state.Actions:
			var err = players[action.Id].Do(action)
			if err != null:
				print(err)
	for id in players:
		players[id].Update()
	for id in units.keys():
		units[id].Update()
	for b in bullets:
		b.Update()
	for s in skills:
		s.Update()
	removeDeadUnits()
	removeExpiredBullets()
	removeExpiredSkills()
	world.Step()
	step += 1
	validate(state)
	
	# client only
	elapsed = 0
	update_time()
	update_energy_boost()

func validate(state):
	if connected and config.CHECK_DESYNC:
		var client_hash = Hash()
		var server_hash = state.Hash
		if client_hash != server_hash:
			print("desync detected")
			print("game id: %s" % cfg.Id)
			print("step: %s" % step)
			print("client hash: %s" % client_hash)
			print("server hash: %s" % server_hash)
			print(to_json(State()))
			get_tree().paused = true

func update_time():
	var time_left
	if step < data.PlayTime:
		time_left = data.PlayTime - step
		$UI/Hud/Time/Text.text ="Time Left"
	else:
		time_left = data.PlayTime + data.OverTime - step
		$UI/Hud/Time/Text.text ="Sudden Death"
	var sec = time_left / data.StepPerSec
	$UI/Hud/Time/Remaining.text = "%d:%02d" % [sec/60, sec%60]

func update_energy_boost():
	if step > data.EnergyBoostAfter:
		boost_fx.visible = true
		boost_ui.visible = true
	else:
		boost_fx.visible = false
		boost_ui.visible = false
	
func removeDeadUnits():
	for id in units.keys():
		var u = units[id]
		if u.IsDead():
			units.erase(id)
			if u.Type() != data.Knight:
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

func removeExpiredSkills():
	var filtered = []
	for s in skills:
		if s.IsExpired():
			s.Destroy()
		else:
			filtered.append(s)
	skills = filtered

func AddUnit(name, level, posX, posY, player):
	unitCounter += 1
	var id = unitCounter
	var path = loading_screen.GetUnitScenePath(name)
	var node = loading_screen.LoadResource(path).instance()
	node.Init(id, level, posX, posY, self, player)
	$BattleField/Unit.add_child(node)
	units[id] = node
	return node

func FindUnit(id):
	if units.has(id):
		return units[id]
	else:
		return null

func AddBullet(bullet):
	$BattleField/Bullet.add_child(bullet)
	bullets.append(bullet)

func AddSkill(s, has_logic = true):
	if has_logic:
		skills.append(s)
	$BattleField/Skill.add_child(s)

func World():
	return world

func Map():
	return map

func UnitIds():
	return units.keys()

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
	var tw = world.ToPixel(map.TileWidth())
	var th = world.ToPixel(map.TileHeight())
	return [x*tw + tw/2, y*th + th/2]

func NewTileRect(x, y, numX, numY):
	return {
		"x": x,
		"y": y,
		"numX": numX,
		"numY": numY,
	}

func TileRectMinX(tr):
	return tr.x - tr.numX/2

func TileRectMaxX(tr):
	return tr.x + (tr.numX+1)/2 - 1

func TileRectMinY(tr):
	return tr.y - tr.numY/2

func TileRectMaxY(tr):
	return tr.y + (tr.numY+1)/2 - 1
	
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

static func boxVScircle(posAx, posAy, posBx, posBy, width, height, radius):
	var relPosX = scalar.Sub(posBx, posAx)
	var relPosY = scalar.Sub(posBy, posAy)
	var closestX = relPosX
	var closestY = relPosY
	var xExtent = width
	var yExtent = height
	closestX = scalar.Clamp(closestX, -xExtent, xExtent)
	closestY = scalar.Clamp(closestY, -yExtent, yExtent)
	if relPosX == closestX and relPosY == closestY:
		return true
	var normalX = scalar.Sub(relPosX, closestX)
	var normalY = scalar.Sub(relPosY, closestY)
	var d = vector.LengthSquared(normalX, normalY)
	if d > scalar.Mul(radius, radius):
		return false
	return true
