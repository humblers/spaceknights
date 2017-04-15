extends Spatial

func _ready():
	
	var player = constants.KNIGHTS[variants.player1_knight["type"]]["scene"].instance()
	var enemy = constants.KNIGHTS[variants.player2_knight["type"]]["scene"].instance()
	player.set_translation(Vector3 ( 0, 0, 18 ))
	player.forward = Vector3(0, 0, -1)
	player.is_enemy = false
	player.is_ai = false
	enemy.set_translation(Vector3 ( 0, 0, -18 ))
	enemy.forward = Vector3(0, 0, 1)
	enemy.set_rotation_deg(Vector3(0, 180, 0))
	enemy.is_enemy = true
	enemy.is_ai = true
	player.set_name("Player")
	enemy.set_name("Enemy")
	get_node('/root/World').add_child(player)
	get_node('/root/World').add_child(enemy)