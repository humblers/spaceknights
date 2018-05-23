extends Node

var finding = false
var find_timer = Timer.new()
var find_stack = 0

onready var match_root = get_node("Match")
onready var find_match = get_node("Match/Find")
onready var instruct_match = get_node("Match/Instruct")
onready var cancel_match = get_node("Match/Cancel")
onready var waiting_match = get_node("Match/Waiting")

func _ready():
	http_lobby.connect("candidacy_response", self, "_candidacy_response")
	http_lobby.connect("withdraw_response", self, "_withdraw_response")
	http_lobby.connect("findgame_response", self, "_findgame_response")
	find_match.connect("pressed", self, "match_candidacy")
	instruct_match.connect("pressed", self, "instruct")
	cancel_match.connect("pressed", self, "withdraw_match")
	find_timer.connect("timeout", self, "find_game")
	find_timer.set_wait_time(0.1)
	add_child(find_timer)
	$Auth.connect("auth_updated", self, "auth_updated")
	$Auth.try_auto_login()

func auth_updated():
	handle_match_buttons()
	find_game(false)

func handle_match_buttons():
	if not global.id:
		match_root.hide()
		return
	match_root.show()
	if finding:
		find_match.hide()
		instruct_match.hide()
		waiting_match.show()
		cancel_match.show()
		return
	find_match.show()
	instruct_match.show()
	waiting_match.hide()
	cancel_match.hide()

func match_candidacy():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/match/candidacy",
			{
				"deck": $Deck.get_selected_units(),
				"knights": $Deck.get_selected_knights(),
			},
			"candidacy_response")

func instruct():
	http_lobby.request(HTTPClient.METHOD_POST,
			"/match/instruct",
			{
				"deck": $Deck.get_selected_units(),
				"knights": $Deck.get_selected_knights(),
			},
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
	tcp.connect_server(dict.host, 9999)
	tcp.send({"Id": global.id, "Token": global.id})
	tcp.send({"SessionId": dict.sid})
	get_tree().change_scene_to(resource.game)
