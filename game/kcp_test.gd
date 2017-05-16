extends Node

var kcp

func _process(delta):
	kcp.update()
	var response = kcp.read()
	if response:
		print (response)

func _ready():
	kcp = Kcp.new()
	kcp.dial("127.0.0.1", 9999)
	kcp.write("hello\n")
	set_process(true)
