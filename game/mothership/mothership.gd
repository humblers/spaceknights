extends StaticBody

export var HP_MAX = 10000
export var is_enemy = false
var hp

func _ready():
	if is_enemy:
		get_node("HP").set_pos(Vector2(260, 8))
	else:
		get_node("HP").set_pos(Vector2(260, 602))
	hp = HP_MAX
	update_ui()

func _on_Area_body_enter( body ):
	if (!is_enemy && body.is_in_group("enemy_Bullet")) || (is_enemy && body.is_in_group("player_Bullet")):
		hp = clamp(hp - body.damage, 0, HP_MAX)
		update_ui()
		body.queue_free()

func update_ui():
	if is_enemy:
		get_node('HP').set_text('Mothership : ' + str(hp))
		if hp <= 0:
			Globals.set("blue_result", Globals.get("blue_result") +1 )
			get_tree().change_scene("res://ui/main_menu.tscn")
	else:
		get_node('HP').set_text('Mothership : ' + str(hp))
		if hp <= 0:
			Globals.set("red_result", Globals.get("red_result") +1 )
			get_tree().change_scene("res://ui/main_menu.tscn")
		
	