extends Node2D

var connected = false
var cfg

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


func _ready():
	map = $Resource/Map.get_resource(cfg.MapName).new(world)
	initTiles()
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
	#event.emit_signal("GameInitialized", self)
	opening_anim.Play()
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

func request_stop():
	to_stop = true

func stop():
	set_process(false)
	set_physics_process(false)

func Step():
	return step

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

			b.node.position = prev.linear_interpolate(curr, t)
			
func _physics_process(delta):
	if frame % frame_per_step == 0:
		var state = {"Actions": null}
		if actions.has(step):
			state["Actions"] = actions[step]
		Update(state)
	
	frame += 1

func State():
	var state = {
		"step": step,
		"unitCounter": unitCounter,
		"world": world.State(),
		"units": {},
		"bullets": [],
		"skills": [],
	}
	for id in units:
		state["units"][id] = units[id].State()
	for b in bullets:
		state["bullets"].append(b.State())
	for s in skills:
		state["skills"].append(s.State())

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
	
	# client only
	elapsed = 0
	update_time()
	update_energy_boost()
	

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
	
func FlipX(x):
	return world.ToPixel(map.Width()) - x

func FlipY(y):
	return world.ToPixel(map.Height()) - y
	
func TileFromPos(x, y):
	var tx = int(clamp(x / world.ToPixel(map.TileWidth()), 0, map.TileNumX() - 1))
	var ty = int(clamp(y / world.ToPixel(map.TileHeight()), 0, map.TileNumY() - 1))
	return [tx, ty]

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