extends Node

const LOBBY_HOST = "13.125.74.237"
const LOBBY_PORT = 8080

var uid

func _ready():
	var err = http.connect_to_host(LOBBY_HOST, LOBBY_PORT)
	if err != OK:
		print("connect to lobby fail: ", err)
		handle_error("Connect to lobby fail!!")
		return
	login()
	load_data()

# simply all error back to login process
func handle_error(message):
	$Modal.pop(message)
	yield($Modal, "popup_hide")
	get_tree().change_scene("res://lobby/lobby.tscn")
	return

func login():
	var req = http.new_request(HTTPClient.METHOD_POST, "/auth/login",
			{ "ptype": "dev", "pid": "", })
	var response = yield(req, "response")
	if not response[0]:
		handle_error(response[1].ErrMessage)
		return
	uid = response[1].UID
	var user = response[1].User
	$HUD.init(user.Level, user.Exp, user.Galacticoin, user.Dimensium)
	$Battle/Mid/Match.connect("pressed", self, "match_request")

func load_data():
	var overwrite = false # set true when production level
	for path in ["Cards", "Units"]:
		var response = yield(http.new_request(HTTPClient.METHOD_POST, "/data/%s" % path.to_lower()), "response")
		if not response[0]:
			handle_error(response[1].ErrMessage)
			return
		stat.set_data(path.to_lower(), response[1][path], overwrite)

func match_request():
	var req = http.new_request(HTTPClient.METHOD_POST, "/match/request")
	$Battle/Requesting.pop(req, 30)
	var resp = yield(req, "response")
	var cfg = resp[1].Config
	tcp.Connect(resp[1].Address, 9999)
	yield(tcp, "connected")
	tcp.Send({"Id": uid, "Token": uid})
	tcp.Send({"GameId": cfg.Id})
	queue_free()
	var g = preload("res://game/game.tscn").instance()
	g.connected = true
	g.cfg = cfg
	get_tree().get_root().add_child(g)