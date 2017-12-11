extends Node

const UPDATES_PER_SECOND = 30

var client = StreamPeerTCP.new()
var timer = Timer.new()
var packets = []
var received = []
var packet_size = 0

signal packet_received(dict)

func _ready():
	timer.set_wait_time(1.0/UPDATES_PER_SECOND)
	timer.connect("timeout", self, "_update")
	add_child(timer)

func connect_server(ip, port):
	assert(client.is_connected() == false)
	if client.connect(ip, port) == OK:
		packets.clear()
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
	if packet_size <= 0 && n >= 2:
		packet_size = client.get_u16()
		n -= 2
	if n >= packet_size:
		var ret = client.get_data(packet_size)
		var err = ret[0]
		var packet = ret[1]
		if err == OK:
			dict.parse_json(packet.get_string_from_utf8())
			packet_size = 0
			print("tcp read: %s" % dict)
		else:
			print("tcp get_data failed: %s" % err)

	# write
	for p in packets:
		client.put_utf8_string(p)
		#print("tcp write: " + p)
	packets.clear()
	
	# logic
	if not dict.empty():
		emit_signal("packet_received", dict)
