extends Control

const LOBBY_HOST = "13.125.74.237"
const LOBBY_PORT = 8080

func _ready():
	var dx = self.rect_size.x - $Pages/Viewer/Control.rect_size.x
	$Pages/Viewer/Control.margin_left -= dx / 2
	$Pages/Viewer/Control.margin_right += dx / 2

	for page in ["Battle", "Card"]:
		$Pages/Viewer/Control/Bot.get_node(page).connect("button_up", self, "move_to_page", [page])

	var err = http.connect_to_host(LOBBY_HOST, LOBBY_PORT)
	if err != OK:
		print("connect to lobby fail: ", err)
		http.handle_error("Connect to lobby fail!!")
		return
	http.modal_dialog = $Modal
	load_data()

func load_data():
	var overwrite = false # set true when production level
	for path in ["Cards", "Units"]:
		var response = yield(http.new_request(HTTPClient.METHOD_POST, "/data/%s" % path.to_lower()), "response")
		if not response[0]:
			http.handle_error(response[1].ErrMessage)
			return
		stat.set_data(path.to_lower(), response[1]["Data"], overwrite)
	login()

func login():
	var req = http.new_request(HTTPClient.METHOD_POST, "/auth/login",
			{ "ptype": "dev", "pid": "", })
	var response = yield(req, "response")
	if not response[0]:
		http.handle_error(response[1].ErrMessage)
		return
	user.Id = response[1].UID
	user.User = response[1].User
	$Pages/Viewer/Control/Top/Level.text = "%d" % (user.User.Level + 1)
	$Pages/Viewer/Control/Top/Level/Exp.text = "%d/xxx" % user.User.Exp
	$Pages/Viewer/Control/Top/Galacticoin.text = "%d" % user.User.Galacticoin
	$Pages/Viewer/Control/Top/Dimensium.text = "%d" % user.User.Dimensium
	$Pages/Battle/Mid/Match.connect("pressed", self, "match_request")
	$Pages/Card.invalidate()

func match_request():
	var req = http.new_request(HTTPClient.METHOD_POST, "/match/request")
	$Pages/Battle/Requesting.pop(req)
	var resp = yield(req, "response")
	var cfg = resp[1].Config
	tcp.Connect(resp[1].Address, 9999)
	yield(tcp, "connected")
	tcp.Send({"Id": user.Id, "Token": user.Id})
	tcp.Send({"GameId": cfg.Id})
	queue_free()
	var g = preload("res://game/game.tscn").instance()
	g.connected = true
	g.cfg = cfg
	get_tree().get_root().add_child(g)

func move_to_page(page):
	var tween = $Pages/Tween
	var viewer = $Pages/Viewer
	var dest = $Pages.get_node("%s/CenterPoint" % page)
	tween.interpolate_property(
			viewer,
			"global_position",
			viewer.global_position,
			dest.global_position,
			0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()