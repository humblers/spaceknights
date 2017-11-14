extends Node

const UPDATES_PER_SECOND = 30

var kcp = Kcp.new()
var timer = Timer.new()
var packets = []

signal packet_received(dict)

func _ready():
	timer.set_wait_time(1.0/UPDATES_PER_SECOND)
	timer.connect("timeout", self, "_update")
	add_child(timer)

func connect_server(ip, port):
	assert(kcp.is_connected() == false)
	if kcp.connect(ip, port):
		timer.start()

func disconnect_server():
	assert(kcp.is_connected() == true)
	timer.stop()
	kcp.disconnect()

func send(dict):
	var packet = dict.to_json() + '\n'
	packets.append(packet)

func _update():
	assert(kcp.is_connected() == true)

	# https://github.com/xtaci/libkcp#usage
	# read
	var dict = {}
	var packet = kcp.read()
	if packet:
		dict.parse_json(packet)

	# write
	for p in packets:
		kcp.write(p)
	packets.clear()
	
	# update
	kcp.update()
	
	# logic
	if not dict.empty():
		emit_signal("packet_received", dict)
