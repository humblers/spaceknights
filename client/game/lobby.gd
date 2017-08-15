extends Node

func _ready():
	http_lobby.connect("login_response", self, "_login_response")
	http_lobby.connect("match_response", self, "_match_response")
	http_lobby.request(HTTPClient.METHOD_POST, "/login/dev", {}, "login_response", false)

func _login_response(success, dict):
	if not success:
		print("login failed : ", dict)
	http_lobby.set_var("uid", dict["id"])
	http_lobby.request(HTTPClient.METHOD_POST, "/match/find", {}, "match_response")

func _match_response(success, dict):
	if not success:
		print("match failed : ", dict)
	http_lobby.set_var("game_host", dict["host"])
	http_lobby.set_var("game_sessionid", dict["sid"])
	get_tree().change_scene("res://game.tscn")
