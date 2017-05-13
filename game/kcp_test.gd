extends Node

var kcp

func _process(delta):
	kcp.update()
	kcp.read()

func _ready():
	kcp = Kcp.new()
	kcp.dialWithOptions("127.0.0.1", 9999, 2, 2)
	kcp.write("hello")
	set_process(true)
