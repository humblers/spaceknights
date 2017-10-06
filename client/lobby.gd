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
	global.id = dict["id"]
	http_lobby.request(HTTPClient.METHOD_POST, "/match/find", {}, "match_response")

func _match_response(success, dict):
	if not success:
		print("match failed : ", dict)

	# kcp connect before scene loading
	kcp.connect_server(dict["host"], 9999)
	kcp.send({"Id": global.id, "Token": global.id})
	kcp.send({"SessionId": dict["sid"]})
	get_tree().change_scene("res://game.tscn")