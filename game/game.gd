extends Node2D

const ID = "alice"
const SESSION_ID = "test"

func _ready():
	kcp._connect("127.0.0.1", 9999)
	kcp.send({"Id": ID, "Token": ID})
	kcp.send({"SessionId": SESSION_ID})
	kcp.connect("packet_received", self, "update_game_state")
	input.connect("mouse_dragged", self, "send_player_input")

func _exit_tree():
	kcp._disconnect()

func send_player_input(x):
	kcp.send({ "Move" : x })
	
func update_game_state(dict):
	var players = dict.Players
	for id in players:
		var player = players[id]
		get_node(id + "/knight").set_pos(Vector2(player.Position, 0))
