extends Node

var packets = []
var kcp
var id = OS.get_unix_time()

func _process(delta):
	kcp.update()
	var packet = kcp.read()
	if packet:
		var dict = {}
		dict.parse_json(packet)
		if dict.id != id:
			packets.append(dict)
			print (dict)

func _ready():
	kcp = Kcp.new()
	kcp.dial("127.0.0.1", 9999)
	set_process(true)

func write(msg):
	msg["id"] = id
	kcp.write(msg.to_json() + '\n')
