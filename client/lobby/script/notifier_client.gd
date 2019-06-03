extends Node

const DEFAULT_HOST = '13.125.74.237'
const DEFAULT_PORT = 9998
const PACKET_TERMINATOR = '\n'

var client = StreamPeerTCP.new()
var client_connected = false

var send_buf = ""
var receive_buf = ""

signal connected
signal disconnected
signal game_created(cfg)
signal prev_game_exists(cfg)

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "ping")
	timer.start(10)
	connect("disconnected", self, "restart_app")

func restart_app():
	loading_screen.GoToScene("res://company_logo/company_logo.tscn")

func _notification(what):
	# application foreground/background handling for future implementation
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		print("focus in")
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		print("focus out")
	
func ping():
	if client_connected:
		Send("PING")
	
func Connect(ip, port):
	if ip == null:
		ip = DEFAULT_HOST
	if port == null:
		port = DEFAULT_PORT
	var err = client.connect_to_host(ip, port)
	if err != OK:
		print("[notifier] tcp Connect failed: %s" % err)

func Disconnect():
	client.disconnect_from_host()

func Send(val):
	if client_connected:
		var packet = to_json(val) + PACKET_TERMINATOR
		send_buf = send_buf + packet
	else:
		print("[notifier] tcp Send failed: client not connected")

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
			parse(packet)
	else:
		print("[notifier] tcp read failed: %s" % err)
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
			print("[notifier] tcp write failed: %s" % err)
			client_connected = false
			emit_signal("disconnected")

func parse(packet):
	var dict = static_func.cast_float_to_int(parse_json(packet))
	if dict.has("GameCreated"):
		emit_signal("game_created", dict["GameCreated"])
	elif dict.has("PrevGameExists"):
		emit_signal("prev_game_exists", dict["PrevGameExists"])