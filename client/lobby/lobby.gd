extends Control

const PAGE_SIZE_X = 1440
const LOBBY_HOST = "13.125.74.237"
const LOBBY_PORT = 8080

func _ready():
	for page in ["Battle", "Card"]:
		var btn = $Bot.get_node(page)
		btn.connect("button_up", self, "move_to_page", [btn])

	var err = http.connect_to_host(LOBBY_HOST, LOBBY_PORT)
	if err != OK:
		print("connect to lobby fail: ", err)
		http.handle_error("Connect to lobby fail!!")
		return
	http.modal_dialog = $Modal
	load_data()

func load_data():
	var response = yield(http.new_request(HTTPClient.METHOD_POST, "/data/cards"), "response")
	if not response[0]:
		http.handle_error(response[1].ErrMessage)
		return
	stat.cards = converter.cast_float_to_int(parse_json(response[1]["Data"]))
	response = yield(http.new_request(HTTPClient.METHOD_POST, "/data/units"), "response")
	if not response[0]:
		http.handle_error(response[1].ErrMessage)
		return
	stat.units = converter.cast_float_to_int(parse_json(response[1]["Data"]))
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
	$Top/Level.text = "%d" % (user.User.Level + 1)
	$Top/Level/Exp.text = "%d/xxx" % user.User.Exp
	$Top/Galacticoin.text = "%d" % user.User.Galacticoin
	$Top/Dimensium.text = "%d" % user.User.Dimensium
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

func move_to_page(btn):
	var tween = $Tween
	var btns = ["Shop", "Card", "Battle", "Explore", "Social"]
	var to = btn.get_name()
	var cur = btn.group.get_pressed_button().get_name()
	var dx = (btns.find(cur) - btns.find(to)) * PAGE_SIZE_X
	var page_pos = $Pages.rect_position
	tween.interpolate_property(
			$Pages,
			"rect_position",
			page_pos,
			Vector2(page_pos.x + dx, page_pos.y),
			0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()