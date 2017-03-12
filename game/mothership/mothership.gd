extends StaticBody

export var HP_MAX = 100
export var is_enemy = false
var hp = HP_MAX

func _ready():
	if is_enemy:
		get_node("HP").set_pos(Vector2(126, 8))
	else:
		get_node("HP").set_pos(Vector2(126, 602))
	update_ui()

func _on_Area_body_enter( body ):
	if body.is_in_group("Bullet"):
		hp = clamp(hp - body.damage, 0, HP_MAX)
		update_ui()
		body.queue_free()

func update_ui():
	if is_enemy:
		get_node('HP').set_text('Enemy Mothership HP : ' + str(hp))
	else:
		get_node('HP').set_text('Player Mothership HP : ' + str(hp))