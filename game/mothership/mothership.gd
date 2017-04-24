extends StaticBody

var HP_MAX = 20000
export var is_enemy = false
var hp


func _ready():
	if not is_network_master():
		if is_enemy:
			set_name("PlayerMothership")
		else:
			set_name("EnemyMothership")
	add_to_group('enemy' if is_enemy else 'player')
	add_to_group('mothership')
	hp = HP_MAX
	update_ui()

func _on_Area_body_enter( body ):
	if not is_network_master():
		return
	if not variants.is_opponent(self, body):
		return
	if body.is_in_group("bullet") or body.is_in_group("charge") or body.is_in_group("drone"):
		rpc("take_damage", body.damage)

sync func take_damage(damage):
	hp = max(hp - damage, 0)
	update_ui()

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
	