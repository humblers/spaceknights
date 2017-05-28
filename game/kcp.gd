extends Node

const READ_RATE = 30 # reads per second
var id = OS.get_unix_time()
var kcp
var timer = Timer.new()
signal packet_received(dict)
signal match_opponent(dict)
var packets = []

func _read():
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
	kcp.dial("192.168.1.3", 9999)

func write(dict):
	dict["id"] = id
	var packet = dict.to_json() + '\n'
	packets.append(packet)