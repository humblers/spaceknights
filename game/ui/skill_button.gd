extends Button

var skill_type = 0

func _ready():
	pass

func _on_Button_pressed():
	if skill_type <= 0:
		#ToDo : make error
		pass
	start.player1_skill_queue.erase(skill_type)
	queue_free()
