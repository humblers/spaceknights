extends Node2D

const WORLD = preload("res://game/script/physics/world.gd")
const MAP = preload("res://game/script/nav/thanatos.gd")

const STEP_PER_SEC = 10
const FRAME_PER_STEP = Engine.iterations_per_second / STEP_PER_SEC
const PACKET_WINDOW = 5
const INPUT_DELAY_STEP = 10

var cfg = {
	"Id": "BEEF",
	"Players": [{"Id": "Alice"}, {"Id": "Bob"}],
}

# current simulation step
var step = 0

# parameters for physics world
var params = {
	"scale": scalar.Div(scalar.One, scalar.FromInt(10)),
	"dt": scalar.Div(scalar.One, scalar.FromInt(STEP_PER_SEC)),
	"gravity_y": 0,
	"restitution": scalar.Div(scalar.One, scalar.FromInt(10)),
}

var world = WORLD.new(params)
var map = MAP.new(params.scale)

# client physics frame
var frame = 0

# states buffer replay load/save
var states = []

# for stop signal
var to_stop = false

# is current game for replay?
var replay = false

func _ready():
	replay = scene_switcher.get_param("replay")
	if replay:
		load_replay()
	else:
		tcp.connect("disconnected", self, "request_stop")
		set_process_input(true)
	set_physics_process(true)
	set_process(true)
	CreateMap()

func request_stop():
	to_stop = true

func stop():
	set_physics_process(false)
	set_process(false)
	if not replay:
		set_process_input(false)
		save_replay()

func CreateMap():
	for o in map.GetObstacles():
		var width = world.ToPixel(map.Width(o))
		var height = world.ToPixel(map.Height(o))
		var x = world.ToPixel(map.PosX(o))
		var y = world.ToPixel(map.PosY(o))
		var b = world.AddBox(
			scalar.FromInt(0),
			world.FromPixel(width),
			world.FromPixel(height),
			world.FromPixel(x),
			world.FromPixel(y)
		)

func _input(event):
	if event is InputEventMouseButton and not event.pressed:
		var x = int(event.position.x)
		var y = int(event.position.y)
		tcp.Send({
				"Step": step + INPUT_DELAY_STEP,
				"Action": {
					"Id": "Alice",
					"PosX": x,
					"PosY": y,
				},
		})
		

func _physics_process(delta):
	if frame % FRAME_PER_STEP == 0:
		if replay:
			if states.size() > 0:
				update(states.pop_front())
			else:
				stop()
		else:
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
	if not replay:
		states.append(state)
	apply(state)
	for node in $units.get_children():
		node.update(step)
	world.Step()
	
	# validate
	if step != state.Step:
		print("step mismatch: %s - %s" % [step, state.Step])
	var client_hash = world.Digest()
	var server_hash = state.Hash
	if client_hash != server_hash:
		print("desync detected: %s - %s" % [client_hash, server_hash])

	step += 1

func apply(state):
	if state.Actions != null:
		for action in state.Actions:
			pass

func save_replay():
	var f = File.new()
	f.open("user://replay", File.WRITE)
	f.store_line(to_json(cfg))
	for s in states:
		f.store_line(to_json(s))
	f.close()

func load_replay():
	var f = File.new()
	f.open("user://replay", File.READ)
	cfg = parse_json(f.get_line())
	while true:
		var line = f.get_line()
		if line == "":
			break
		var s = parse_json(line)
		states.append(s)
