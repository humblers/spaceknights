extends Spatial

signal game_finished()

func _ready():
	
	var player = constants.KNIGHTS[variants.player1_knight["type"]]["scene"].instance()
	var enemy = constants.KNIGHTS[variants.player2_knight["type"]]["scene"].instance()
	player.set_translation(Vector3 ( 0, 0, 18 ))
	player.forward = Vector3(0, 0, -1)
	player.is_enemy = false
	enemy.set_translation(Vector3 ( 0, 0, -18 ))
	enemy.forward = Vector3(0, 0, 1)
	enemy.set_rotation_deg(Vector3(0, 180, 0))
	enemy.is_enemy = true
	if is_network_master():
		player.set_name("Player")
		enemy.set_name("Enemy")
	else:
		player.set_name("Enemy")
		enemy.set_name("Player")
	get_node('/root/World').add_child(player)
	get_node('/root/World').add_child(enemy)