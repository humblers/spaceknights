extends Node

const UPDATES_PER_SECOND = 30

var kcp = Kcp.new()
var timer = Timer.new()
var packets = []
var connected = false

signal packet_received(dict)

func _ready():
	timer.set_wait_time(1.0/UPDATES_PER_SECOND)
	timer.connect("timeout", self, "_update")
	add_child(timer)

func connect(ip, port):
	if kcp.connect(ip, port):
		connected = true
		timer.start()

func disconnect():
	if connected:
		timer.stop()
		kcp.disconnect()

func write(dict):
	var packet = dict.to_json() + '\n'
	packets.append(packet)
	
func _update():
	# read
	var packet = kcp.read()
	if packet:
		var dict = {}
		dict.parse_json(packet)
		emit_signal("packet_received", dict)

	# write
	for p in packets:
		kcp.write(p)
	packets.clear()
	
	# update
	kcp.update()