extends Node

const FIND_OPPONENT = 1
const MATCH_OPPONENT = 2
const MOVE_KNIGHT = 3

const READ_RATE = 30 # reads per second
var id = OS.get_unix_time()
var kcp
var timer = Timer.new()
signal packet_received(dict)
signal match_opponent(dict)
var packets = []
var uid

func _read():
	uid = randi()
	var packet = kcp.read()
	if packet == null:
		return
	var dict = {}
	dict.parse_json(packet)
	if dict.has("dir"):
		emit_signal("packet_received", dict)
	if dict.has("type") and dict.has("skills"):
		emit_signal("match_opponent", dict)
	for p in packets:
		kcp.write(p)
	packets.clear()
	kcp.update()

func _ready():
	timer.set_wait_time(1.0/READ_RATE)
	timer.connect("timeout", self, "_read")
	add_child(timer)
	timer.start()
	kcp = Kcp.new()
	kcp.dial("127.0.0.1", 9999)

func write(protocol_id, dict):
	var packet = { 
		"protoid" : protocol_id, 
		"uid" : uid,
		"message" : dict,
	}.to_json() + '\n'
	packets.append(packet)