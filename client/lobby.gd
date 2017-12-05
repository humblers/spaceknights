extends Node

var deck
var finding = false
var find_timer = Timer.new()
var find_stack = 0

onready var id_holder = get_node("Auth/IDPlaceholder")
onready var login = get_node("Auth/Login")
onready var logout = get_node("Auth/Logout")
onready var match = get_node("Match")
onready var find_match = get_node("Match/Find")
onready var cancel_match = get_node("Match/Cancel")
onready var waiting_match = get_node("Match/Waiting")
onready var shuffle_deck = get_node("Deck/Shuffle")

func _ready():
	http_lobby.connect("login_response", self, "_login_response")
	http_lobby.connect("candidacy_response", self, "_candidacy_response")
	http_lobby.connect("withdraw_response", self, "_withdraw_response")
	http_lobby.connect("findgame_response", self, "_findgame_response")
	http_lobby.connect("logout_response", self, "_logout_response")
	login.connect("pressed", self, "login_manually")
	logout.connect("pressed", self, "logout")
	find_match.connect("pressed", self, "match_candidacy")
	cancel_match.connect("pressed", self, "withdraw_match")
	shuffle_deck.connect("pressed", self, "shuffle_deck")
	find_timer.connect("timeout", self, "find_game")
	find_timer.set_wait_time(0.1)
	add_child(find_timer)
	shuffle_deck()
	try_auto_login()

func try_auto_login():
	if not global.config.has_section("login"):
		return
	for id in global.config.get_section_keys("login"):
		var token = global.config.get_value("login", id)
		global.config.set_value("login", id, null)
		global.save_config()
		http_lobby.request(HTTPClient.METHOD_POST,
				"/login/dev",
				{"id":id, "token":token},
				"login_response")
		return

func login_manually():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/login/dev",
			{"id":id_holder.get_text()},
			"login_response")

func logout():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/logout",
			{},
			"logout_response")

func handle_match_buttons():
	if not global.id:
		match.hide()
		return
	match.show()
	if finding:
		find_match.hide()
		waiting_match.show()
		cancel_match.show()
		return
	find_match.show()
	waiting_match.hide()
	cancel_match.hide()

func match_candidacy():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/match/candidacy",
			{"deck":deck},
			"candidacy_response")

func find_game(handle_button=true):
	if finding:
		return
	finding = true
	http_lobby.request(HTTPClient.METHOD_POST,
			"/match/find",
			{},
			"findgame_response")
	if handle_button:
		handle_match_buttons()

func withdraw_match():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/match/withdraw",
			{},
			"withdraw_response")
	handle_match_buttons()

func shuffle_deck():
	for child in get_node("Deck/Container").get_children():
		child.queue_free()
	deck = global.shuffle_array(global.CARDS.keys())
	deck.resize(6)
	for card in deck:
		var label = Label.new()
		label.set_text(card)
		get_node("Deck/Container").add_child(label)

func _login_response(success, dict):
	if not success:
		print("login failed : ", dict)
		return
	global.id = dict.id
	global.config.set_value("login", global.id, dict.token)
	global.save_config()
	id_holder.set_text(global.id)
	id_holder.set_editable(false)
	id_holder.set_focus_mode(Control.FOCUS_NONE)
	login.hide()
	logout.show()
	handle_match_buttons()
	find_game(false)

func _logout_response(success, dict):
	handle_match_buttons()
	logout.hide()
	login.show()
	id_holder.set_focus_mode(Control.FOCUS_ALL)
	id_holder.set_editable(true)
	id_holder.set_text("")
	global.config.set_value("login", global.id, null)
	global.save_config()
	global.id = null

func _candidacy_response(success, dict):
	if not success:
		print("match failed : ", dict)
	find_timer.start()

func _withdraw_response(success, dict):
	find_timer.stop()
	find_stack = 0
	finding = false
	handle_match_buttons()

func _findgame_response(success, dict):
	finding = false
	if not success:
		find_stack += 1
		if find_stack > 100:
			withdraw_match()
		return
	find_timer.stop()
	# tcp connect before scene loading
	print(dict)
	tcp.connect_server(dict.host, 9999)
	tcp.send({"Id": global.id, "Token": global.id})
	tcp.send({"SessionId": dict.sid})
	get_tree().change_scene("res://game.tscn")
