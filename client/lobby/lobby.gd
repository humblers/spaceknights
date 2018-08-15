extends Node

func _ready():
	$connect.connect("pressed", self, "connect_to_game_server")

func load_game():
	# TODO: Get game config from lobby server
	var cfg = {
	"Id": "TEST",
	}
	tcp.Send({"Id": $id.text, "Token": $id.text})
	tcp.Send({"GameId": cfg.Id})
	queue_free()
	var g = preload("res://game/game.tscn").instance()
	# TODO: Set received game config
#	g.cfg = cfg
	g.connected = true
	get_tree().get_root().add_child(g)
#	get_tree().change_scene("res://game/game.tscn")

func connect_to_game_server():
	user.Id = $id.text
	tcp.Connect("127.0.0.1", 9999)
	tcp.connect("connected", self, "load_game")