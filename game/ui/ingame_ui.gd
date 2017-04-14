extends Control

var color_disable = Color(0,0,0,1)
var color_enable = Color(0.13,0.58,0.47,1)
var popup_cool = 0

var skill1
var skill2
var skill3
var skill4
var enemy_skill1
var enemy_skill2
var enemy_skill3
var enemy_skill4
var is_pressed = false

func _ready():
	get_node("Skill_status").hide()
	get_node("Error_status").hide()
	set_process(true)

func update_ui(skill_queue, is_enemy):
	for i in range(4):
		var skill = constants.SKILLS[skill_queue[i]]
		if is_enemy:
			get_node("Enemy_skill%d" % [i+1]).set_text("%s\n(%s)" % [skill["name"], skill["energy"]])
			set("enemy_skill%d" % [i+1], skill_queue[i])

		else:
			get_node("Skill%d" % [i+1]).set_text("%s\n(%s)" % [skill["name"], skill["energy"]])
			set("skill%d" % [i+1], skill_queue[i])

func _on_skill1_pressed():
	get_node("/root/World/Player").activate_skill(skill1, 0)

func _on_skill2_pressed():
	get_node("/root/World/Player").activate_skill(skill2, 1)
	
func _on_skill3_pressed():
	get_node("/root/World/Player").activate_skill(skill3, 2)
	
func _on_skill4_pressed():
	get_node("/root/World/Player").activate_skill(skill4, 3)

func _on_enemy_skill1_pressed():
	get_node("/root/World/Enemy").activate_skill(enemy_skill1, 0)

func _on_enemy_skill2_pressed():
	get_node("/root/World/Enemy").activate_skill(enemy_skill2, 1)
	
func _on_enemy_skill3_pressed():
	get_node("/root/World/Enemy").activate_skill(enemy_skill3, 2)
	
func _on_enemy_skill4_pressed():
	get_node("/root/World/Enemy").activate_skill(enemy_skill4, 3)

func _process(delta):
	popup_cool -= delta
	if popup_cool <= 0:
		popup_cool = 0
		get_node("Error_status").hide()		
	get_node("Energy_bar").set_value(get_node("/root/World/Player").energy/get_node("/root/World/Player").MAX_ENERGY)
	get_node("Enemy_energy_bar").set_value(get_node("/root/World/Enemy").energy/get_node("/root/World/Enemy").MAX_ENERGY)	
	
	if Input.is_key_pressed(KEY_1):
		if !is_pressed:
			is_pressed = true
			_on_skill1_pressed()
	elif Input.is_key_pressed(KEY_2):
		if !is_pressed:
			is_pressed = true
			_on_skill2_pressed()
	elif Input.is_key_pressed(KEY_3):
		if !is_pressed:
			is_pressed = true
			_on_skill3_pressed()
	elif Input.is_key_pressed(KEY_4):
		if !is_pressed:
			is_pressed = true
			_on_skill4_pressed()
	elif Input.is_key_pressed(KEY_KP_1):
		if !is_pressed:
			is_pressed = true
			_on_enemy_skill1_pressed()
	elif Input.is_key_pressed(KEY_KP_2):
		if !is_pressed:
			is_pressed = true
			_on_enemy_skill2_pressed()
	elif Input.is_key_pressed(KEY_KP_3):
		if !is_pressed:
			is_pressed = true
			_on_enemy_skill3_pressed()
	elif Input.is_key_pressed(KEY_KP_4):
		if !is_pressed:
			is_pressed = true
			_on_enemy_skill4_pressed()
	else:
		is_pressed = false

func show_error_status():
	get_node("Error_status").set_text("NO ENERGY")
	get_node("Error_status").show()
	popup_cool = 0.3
