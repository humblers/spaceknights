extends Node

const UPDATES_PER_SECOND = 60

var kcp = Kcp.new()
var timer = Timer.new()
var packets = []
var recv = ""

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

func is_connected():
	return kcp.is_connected()

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