extends StaticBody

export var HP_MAX = 10000
export var is_enemy = false
var hp
onready var gameover = false

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
	if (!is_enemy && body.is_in_group("enemy_Laser")) || (is_enemy && body.is_in_group("player_Laser")):
		hp = clamp(hp - body.damage, 0, HP_MAX)
		update_ui()

func update_ui():
	get_node('HP').set_text('Mothership : ' + str(hp))
	if hp <= 0 and not gameover:
		if is_enemy:
			start.blue_score += 1
		else:
			start.red_score += 1
		gameover = true
		var popup = preload('res://ui/score_popup.tscn').instance()
		get_node('../').add_child(popup)
		#get_tree().change_scene("res://ui/main_menu.tscn")
	