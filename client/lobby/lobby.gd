extends Node

func _ready():
	$connect.connect("pressed", self, "connect_to_game_server")

func load_game():
	tcp.Send({"Id": $id.text, "Token": $id.text})
	tcp.Send({"GameId": cfg.Id})
	queue_free()
	var g = preload("res://game/game.tscn").instance()
	g.cfg = cfg
	g.connected = true
	get_tree().get_root().add_child(g)
#	get_tree().change_scene("res://game/game.tscn")

func connect_to_game_server():
	user.Id = $id.text
	tcp.Connect("127.0.0.1", 9999)
	tcp.connect("connected", self, "load_game")

var cfg = {
	"Id": "TEST",
	"MapName": "Thanatos",
	"Players": [
		{
			"Id": "Alice",
			"Team": "Blue",
			"Deck": [
				{"Name": "fireball", "Level": 0},
				{"Name": "archers", "Level": 0},
				{"Name": "shadowvision", "Level": 0},
				{"Name": "fireball", "Level": 0},
				{"Name": "archers", "Level": 0},
				{"Name": "archers", "Level": 0},
				{"Name": "fireball", "Level": 0},
				{"Name": "shadowvision", "Level": 0},
			],
			"Knights": [
				{"Name": "legion", "Level": 0},
				{"Name": "legion", "Level": 0},
				{"Name": "legion", "Level": 0},
			],
		},
		{
			"Id": "Bob",
			"Team": "Red",
			"Deck": [
				{"Name": "fireball", "Level": 0},
				{"Name": "shadowvision", "Level": 0},
				{"Name": "archers", "Level": 0},
				{"Name": "shadowvision", "Level": 0},
				{"Name": "archers", "Level": 0},
				{"Name": "fireball", "Level": 0},
				{"Name": "fireball", "Level": 0},
				{"Name": "archers", "Level": 0},
			],
			"Knights": [
				{"Name": "legion", "Level": 0},
				{"Name": "legion", "Level": 0},
				{"Name": "legion", "Level": 0},
			],
		}
	],
}