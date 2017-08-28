extends Node

const UPDATES_PER_SECOND = 30

var kcp = Kcp.new()
var timer = Timer.new()
var packets = []
var recv = ""
var connected = false

signal packet_received(dict)

func _ready():
	timer.set_wait_time(1.0/UPDATES_PER_SECOND)
	timer.connect("timeout", self, "_update")
	add_child(timer)

func _connect(ip, port):
	if kcp.connect(ip, port):
		connected = true
		timer.start()

func _disconnect():
	if connected:
		timer.stop()
		kcp.disconnect()
		connected = false

func send(dict):
	var packet = dict.to_json() + '\n'
	packets.append(packet)
	
func _update():
	# https://github.com/xtaci/libkcp#usage
	# read
	var dict = {}
	var packet = kcp.read()
	if packet:
		recv += packet
		if recv.ends_with("\n"):
			dict.parse_json(recv)
			recv = ""

	# write
	for p in packets:
		kcp.write(p)
	packets.clear()
	
	# update
	kcp.update()
	
	# logic
	if not dict.empty():
		emit_signal("packet_received", dict)
