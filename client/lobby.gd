extends Node

func _ready():
	if kcp.is_connected():
		kcp.disconnect_server()
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

	# kcp connect before scene loading
	var id = http_lobby.get_var("uid")
	var session_id = http_lobby.get_var("game_sessionid")
	kcp.connect_server(http_lobby.get_var("game_host"), 9999)
	kcp.send({"Id": id, "Token": id})
	kcp.send({"SessionId": session_id})
	get_tree().change_scene("res://game.tscn")
