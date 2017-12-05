extends Node

const UPDATES_PER_SECOND = 30

var client = StreamPeerTCP.new()
var timer = Timer.new()
var packets = []
var received = ""

signal packet_received(dict)

func _ready():
	timer.set_wait_time(1.0/UPDATES_PER_SECOND)
	timer.connect("timeout", self, "_update")
	add_child(timer)

func connect_server(ip, port):
	assert(client.is_connected() == false)
	if client.connect(ip, port) == OK:
		timer.start()

func disconnect_server():
	assert(client.is_connected() == true)
	timer.stop()
	client.disconnect()

func send(dict):
	var packet = dict.to_json() + '\n'
	packets.append(packet)

func _update():
	assert(client.is_connected() == true)

	# read
	var dict = {}
	var n = client.get_available_bytes()
	received += client.get_utf8_string(n)
	var pos = received.find('\n')
	if pos >= 0:
		var packet = received.left(pos + 1)
		received = received.right(pos + 1)
		dict.parse_json(packet)
		print("tcp read: " + packet)

	# write
	for p in packets:
		client.put_utf8_string(p)
		print("tcp write: " + p)
	packets.clear()
	
	# logic
	if not dict.empty():
		emit_signal("packet_received", dict)