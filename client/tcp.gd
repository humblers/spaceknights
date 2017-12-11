extends Node

const UPDATES_PER_SECOND = 30
const HEADER_SIZE = 4

var client = StreamPeerTCP.new()
var timer = Timer.new()
var packets = []
var received_header = false
var nCompressed = 0
var nDecompressed = 0

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
	if not received_header && n >= HEADER_SIZE:
		nCompressed = client.get_u16()
		nDecompressed = client.get_u16()
		n -= HEADER_SIZE
		received_header = true
	if received_header and n >= nCompressed:
		var ret = client.get_data(nCompressed)
		var err = ret[0]
		var compressed = ret[1]
		if err == OK:
			var decompressed = compressed.decompress(nDecompressed)
			dict.parse_json(decompressed.get_string_from_utf8())
			received_header = false
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
