extends Node2D

var connected = false
var cfg = config.GAME
var dt = scalar.Div(scalar.One, scalar.FromInt(data.StepPerSec))

const LEADER_SCORE = 3
const WING_SCORE = 1

enum PHASES {
	INITIAL,
	FOOTMANS,
	END,
}

var frame_per_step = Engine.iterations_per_second / data.StepPerSec
onready var phase = PHASES.INITIAL

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

func _ready():
	AddHero()
	#opening_anim.Play()
	
	#AddUnit("valkyrie", 1, 500, 500)


func Update():
	
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
	
	match phase:
		PHASES.INITIAL:
			ForwardToNextPhase(1)
		PHASES.FOOTMANS:
			AddUnit("footman",1,500,1000)
			AddUnit("berserker",1,500,500)

func ForwardToNextPhase(time):
	if step / data.StepPerSec > time:
		ForwardToPhase(phase + 1)

func ForwardToPhase(phase):
	self.phase = phase
	
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

func AddUnit(name, level, posX, posY):
	unitCounter += 1
	var id = unitCounter
	var node = $Resource/Unit.get_resource(name).instance()
	node.Init(id, level, posX, posY, self)
	$BattleField/Unit.add_child(node)
	units[id] = node
	return node

func AddHero():
	unitCounter += 1
	var node = get_node("BattleField/Unit/Protagonist/Valkyrie")
	node.New("valkyrie", "Blue", 1, 500, 500, self)
	units[0] = node
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

func UnitIds():
	return units.keys()
	
func _physics_process(delta):
	if frame % frame_per_step == 0:
		Update()	
	frame += 1
