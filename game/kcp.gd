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
	for p in packets:
		kcp.write(p)
	packets.clear()
	kcp.update()
	
	var packet = kcp.read()
	if packet == null:
		return
	var dict = {}
	dict.parse_json(packet)
	if dict.empty():
		return
	if not dict.has("protoid"):
		print("ugly packet", dict)
		return
	var protoid = dict["protoid"]
	if protoid == MATCH_OPPONENT:
		emit_signal("match_opponent", dict)
	else:
		emit_signal("packet_received", dict)

func _ready():
	randomize()
	uid = randi()
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