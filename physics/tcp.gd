extends Node

const PACKET_TERMINATOR = '\n'

var client = StreamPeerTCP.new()
var client_connected = false

var send_buf = ""
var receive_buf = ""
var received = []

signal connected
signal disconnected

func _ready():
	set_physics_process(true)

func Connect(ip, port):
	var err = client.connect_to_host(ip, port)
	if err != OK:
		print("tcp Connect failed: %s" % err)

func Disconnect():
	client.disconnect_from_host()

func Send(dict):
	if client_connected:
		var packet = to_json(dict) + PACKET_TERMINATOR
		send_buf = send_buf + packet
	else:
		print("tcp Send failed: client not connected")

func _physics_process(delta):
	if not client_connected:
		if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			client_connected = true
			emit_signal("connected")
		else:
			return
	read()
	write()

func read():
	var n = max(1, client.get_available_bytes())
	var ret = client.get_partial_data(n)
	var err = ret[0]
	var data = ret[1]
	if err == OK:
		receive_buf += data.get_string_from_utf8()
		while true:
			var pos = receive_buf.find(PACKET_TERMINATOR)
			if pos < 0:
				break
			var packet = receive_buf.left(pos)
			receive_buf = receive_buf.right(pos + 1)
			received.append(packet)
	else:
		print("tcp read failed: %s" % err)
		client_connected = false
		emit_signal("disconnected")

func write():
	if send_buf.length() > 0:
		var ret = client.put_partial_data(send_buf.to_utf8())
		var err = ret[0]
		var n = ret[1]
		if err == OK:
			send_buf = send_buf.right(n)
		else:
			print("tcp write failed: %s" % err)
			client_connected = false
			emit_signal("disconnected")
