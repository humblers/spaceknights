extends KinematicBody

const DEFAULT_LIFE_TIME = 10
const DEFAULT_HP = 50
const FORWARD_TYPE_SPEED = 30

var hp = DEFAULT_HP
var life_elapsed = 0
var is_destroyed = false
var collider_damage = 400

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
	
	get_node('HP').set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
	translate(Vector3(0, 0,  -1 * FORWARD_TYPE_SPEED * delta))
	rotate_z(0.3)

func _ready():
	set_translation(get_translation() + Vector3(0,0,-4) if is_in_group('enemy') else Vector3(0, 0, 4))
	hp_label.set_name('HP')
	hp_label.set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
	add_child(hp_label)
	hp_label.set_text('HP : %d' % hp)
	set_fixed_process(true)

func _on_ChargeArea_body_enter( body ):
	if (body.is_in_group("bullet")):
		body.queue_free()
		hp = max(hp - body.damage, 0)
		update_ui()
