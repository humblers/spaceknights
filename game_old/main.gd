extends Spatial

signal game_finished()
const player_id = "alice"

func _ready():
	
	var player = constants.KNIGHTS[variants.player1_knight["type"]]["scene"].instance()
	var enemy = constants.KNIGHTS[variants.player2_knight["type"]]["scene"].instance()
	player.set_translation(Vector3 ( 0, 0, 18 ))
	player.forward = Vector3(0, 0, -1)
	player.is_enemy = false
	player.set_name("Player")
	enemy.set_translation(Vector3 ( 0, 0, -18 ))
	enemy.forward = Vector3(0, 0, 1)
	enemy.set_rotation_deg(Vector3(0, 180, 0))
	enemy.is_enemy = true
	enemy.set_name("Enemy")
	get_node('/root/World').add_child(player)
	get_node('/root/World').add_child(enemy)
	
	kcp.connect("packet_received", self, "_packet_received")
	
func _packet_received(dict):
	for id in dict.Players:
		if id == player_id:
			var position = get_node("/root/World/Player").get_translation()
			position.x = dict.Players[id].Position
			get_node("/root/World/Player").set_translation(position)
		else:
			var position = get_node("/root/World/Enemy").get_translation()
			position.x = dict.Players[id].Position
			get_node("/root/World/Enemy").set_translation(position)
