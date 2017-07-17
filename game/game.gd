extends Node

var Id = "alice"
var SessionId = "test"
var MyTeam = "TeamA"
var EnemyTeam = "TeamB"


var knight_texture_map = {
	"blue": {
		"A": preload("res://shuriken_blue.png"),
		"B": preload("res://space_z_blue.png"),
	},
	"red": {
		"A": preload("res://shuriken_red.png"),
		"B": preload("res://space_z_red.png"),
	},
}
var barbarian_texture_map = {
	"blue": preload("res://barbarian_blue.png"),
	"red": preload("res://barbarian_red.png"),
}

func _ready():
	kcp._connect("127.0.0.1", 9999)
	kcp.send({"Id": Id, "Token": Id})
	kcp.send({"SessionId": SessionId})
	kcp.connect("packet_received", self, "reflect")
	input.connect("mouse_dragged", self, "send_player_input")
	input.connect("mouse_pressed", self, "show_deck")

func _exit_tree():
	kcp._disconnect()
	
func reflect(game):
	update_team(game[MyTeam], get_node("MyTeam"), false)
	update_team(game[EnemyTeam], get_node("EnemyTeam"), true)

func update_team(team, node, invert):
	var players = team.Players
	for id in players:
		if not node.has_node(id):
			var player_node = Node2D.new()
			player_node.set_name(id)
			node.add_child(player_node)
		update_player(players[id], node.get_node(id), invert)
		if id == Id:
			for i in range(3):
				get_node("deck/card" + str(i + 1)).set_text(players[id].Hand[i])
			get_node("deck/next").set_text(players[id].Next)

func update_player(player, node, invert):
	if not node.has_node("knight"):
		var knight_node = Sprite.new()
		knight_node.set_texture(knight_texture_map["red" if invert else "blue"][player.Knight.Type])
		knight_node.set_name("knight")
		node.add_child(knight_node)
	node.get_node("knight").set_pos(Vector2(player.Knight.X, 19.5 * (1 if invert else -1)))
	
	for count in player.Barbarians:
		if not node.has_node("barbarian" + count):
			var barbarian_node = Sprite.new()
			barbarian_node.set_texture(barbarian_texture_map["red" if invert else "blue"])
			barbarian_node.set_name("barbarian" + count)
			node.add_child(barbarian_node)
		node.get_node("barbarian" + count).set_pos(Vector2(player.Barbarians[count].X, 140 * (1 if invert else -1) + player.Barbarians[count].Y))

func send_player_input(x):
	kcp.send({ "Move" : x })

func show_deck(pressed):
	if pressed:
		get_node("deck").hide()
	else:
		get_node("deck").show()

func _on_card1_pressed():
	kcp.send({ "Use" : 1 })

func _on_card2_pressed():
	kcp.send({ "Use" : 2 })

func _on_card3_pressed():
	kcp.send({ "Use" : 3 })
