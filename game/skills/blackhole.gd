extends RigidBody

var is_enemy = true

func _on_BlackHole_body_enter( body ):
	if (body.is_in_group("enemy_Bullet") and not is_enemy) \
	or (body.is_in_group("player_Bullet") and is_enemy):
		body.queue_free()