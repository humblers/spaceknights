extends StaticBody

var HP_MAX = 20000
export var is_enemy = false
var hp


func _ready():
	if is_enemy:
		set_layer_mask(constants.LM_ENEMY)
		set_collision_mask(constants.LM_PLAYER)
	else:
		set_layer_mask(constants.LM_PLAYER)
		set_collision_mask(constants.LM_ENEMY)
	hp = HP_MAX
	update_ui()

func _on_Area_body_enter( body ):
	if (!is_enemy && body.is_in_group("enemy_Bullet")) || (is_enemy && body.is_in_group("player_Bullet")):
		hp = clamp(hp - body.damage, 0, HP_MAX)
		update_ui()
		body.queue_free()
	if (!is_enemy && body.is_in_group("enemy_Laser")) || (is_enemy && body.is_in_group("player_Laser")):
		hp = clamp(hp - body.damage, 0, HP_MAX)
		update_ui()
	if (!is_enemy && body.is_in_group("enemy_Cannon")) || (is_enemy && body.is_in_group("player_Cannon")):
		hp = clamp(hp - body.damage, 0, HP_MAX)
		update_ui()
		body.queue_free()
	if (!is_enemy && body.is_in_group("enemy_Collider")) || (is_enemy && body.is_in_group("player_Collider")):
		hp = clamp(hp - body.collider_damage, 0, HP_MAX)
		update_ui()
		body.queue_free()

func update_ui():
	if is_enemy:
		variants.red_hp = hp
		get_node("../ingame_ui/Mother_hp2/value").set_text(str(round(hp)))
	
	else:
		variants.blue_hp = hp
		get_node("../ingame_ui/Mother_hp1/value").set_text(str(round(hp)))
	
	if hp <= 0 and not variants.gameover:
		if is_enemy:
			variants.blue_score += 1
		else:
			variants.red_score += 1
		variants.gameover = true
		var popup = preload('res://ui/score_popup.tscn').instance()
		get_node('../').add_child(popup)
		#get_tree().change_scene("res://ui/main_menu.tscn")
	