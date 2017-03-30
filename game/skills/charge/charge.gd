extends KinematicBody

const DEFAULT_LIFE_TIME = 10
const DEFAULT_HP = 20
const FORWARD_TYPE_SPEED = 30

var charge_type = constants.CHARGE
var is_enemy = false

var hp = DEFAULT_HP
var life_elapsed = 0
var is_destroyed = false
var collider_damage = 100

onready var hp_label = Label.new()

func update_ui():
	hp_label.set_text('HP : %d' % hp)

func destroy():
	if not is_destroyed:
		set_fixed_process(false)
		queue_free()
		is_destroyed = true

func _fixed_process(delta):
	life_elapsed += delta
	if life_elapsed > DEFAULT_LIFE_TIME or hp <= 0:
		destroy()
		return
	
	if charge_type == constants.CHARGE:
		get_node('HP').set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
		translate(Vector3(0, 0,  -1 * FORWARD_TYPE_SPEED * delta))
		rotate_z(0.3)

func _ready():
	var charge_loc = self.get_translation()	
	if is_enemy:
		add_to_group('enemy_Collider')
		set_layer_mask(constants.LM_ENEMY)
		set_collision_mask(constants.LM_PLAYER)
		self.set_translation(charge_loc + Vector3(0,0,-4))
	else:
		add_to_group('player_Collider')
		set_layer_mask(constants.LM_PLAYER)
		set_collision_mask(constants.LM_ENEMY)
		self.set_translation(charge_loc + Vector3(0,0,4))
	
	hp_label.set_name('HP')
	hp_label.set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
	add_child(hp_label)
	hp_label.set_text('HP : %d' % hp)
	set_fixed_process(true)


func _on_DroneArea_body_enter( body ):
	if (!is_enemy && body.is_in_group("enemy_Bullet")) || (is_enemy && body.is_in_group("player_Bullet")):
		body.queue_free()
		hp = clamp(hp - body.damage, 0, DEFAULT_HP)
		update_ui()
