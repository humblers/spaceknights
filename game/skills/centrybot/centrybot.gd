extends StaticBody

const DEFAULT_LIFE_TIME = 10
const DEFAULT_HP = 200
const DEFAULT_BULLET_COOL_TIME = 1.5
const FORWARD_TYPE_SPEED = 5

var is_enemy = false

var hp = DEFAULT_HP
var search_range = 12

var life_elapsed = 0
var is_destroyed = false
var bullet_elapsed = 0

var bullet_damage = 200
var bullet_decay_time = 20
var bullet_speed = 5
var bullet_scale = 1
var bullet_mass = 1000
var forward = Vector3(0, 0, -1)
var collision_shape = SphereShape.new()

onready var hp_label = Label.new()
onready var mothership = get_node("../%sMothership" % ("Player" if is_enemy else "Enemy"))

func get_distance_to(target):
	return get_translation().distance_to(target.get_translation())

func shot_to_nearest_enemy(delta):
	var enemy = mothership
	for body in get_node("Range").get_overlapping_bodies():
		if body.is_in_group("enemy_Bullet") or body.is_in_group("player_Bullet"):
			continue
		if body.is_in_group("%s_Collider" % ("enemy" if is_enemy else "player")):
			continue
		if body.is_in_group("%s_Cannon" % ("enemy" if is_enemy else "player")):
			continue
		if get_distance_to(body) < get_distance_to(enemy):
			enemy = body
	bullet_elapsed += delta
	if bullet_elapsed > DEFAULT_BULLET_COOL_TIME:
		bullet_elapsed = 0
		create_bullet((enemy.get_translation() - get_translation()).normalized(), Vector3(0, 0, 0))	

func set_bullet_speed(speed):
	bullet_speed(speed)
	
func update_ui():
	hp_label.set_text('HP : %d' % hp)

func destroy():
	if not is_destroyed:
		set_fixed_process(false)
		queue_free()
		is_destroyed = true

func _process(delta):
	life_elapsed += delta
	if life_elapsed > DEFAULT_LIFE_TIME or hp <= 0:
		destroy()
		return
	shot_to_nearest_enemy(delta)

func create_bullet(direction, width = Vector3(0,0,0)):
	var bullet
	bullet = preload('res://bullet/rocket.tscn').instance()
	bullet.is_enemy = is_enemy
	bullet.is_cannon = true
	bullet.damage = bullet_damage
	bullet.decay_time = bullet_decay_time
	bullet_scale = 0.5
	
	var bullet_mesh = bullet.get_node("MeshInstance")
	collision_shape.set_radius(bullet.get_shape(0).get_radius() * bullet_scale)
	bullet.set_shape(0, collision_shape)
	bullet.set_global_transform(get_node("ShotFrom").get_global_transform().orthonormalized())
	bullet.translate(width)
	bullet.set_linear_velocity(direction * bullet_speed) 
	bullet.set_mass(bullet_mass)
	bullet_mesh.set_scale(bullet_mesh.get_scale() * bullet_scale)
	get_node('../').add_child(bullet)
	
func _ready():
	var player = "Enemy" if is_enemy else "Player"
	var player_node = get_node("../%s" % player)
	var trans = player_node.get_global_transform().orthonormalized()
	trans.origin.z = -4 if is_enemy else 4
	set_global_transform(trans)

	hp_label.set_name('HP')
	hp_label.set_pos(get_node('../Camera').unproject_position(get_global_transform().origin))
	add_child(hp_label)
	hp_label.set_text('HP : %d' % hp)
	
	if is_enemy:
		add_to_group('enemy_Collider')
		set_layer_mask(constants.LM_ENEMY)
		set_collision_mask(constants.LM_PLAYER)
	else:
		add_to_group('player_Collider')
		set_layer_mask(constants.LM_PLAYER)
		set_collision_mask(constants.LM_ENEMY)
	set_process(true)

func _on_centrybot_area_body_enter( body ):
	if (!is_enemy && body.is_in_group("enemy_Bullet")) || (is_enemy && body.is_in_group("player_Bullet")):
		body.queue_free()
		hp = clamp(hp - body.damage, 0, DEFAULT_HP)
		update_ui()
	if (!is_enemy && body.is_in_group("enemy_Cannon")) || (is_enemy && body.is_in_group("player_Cannon")):
		hp = clamp(hp - body.damage, 0, DEFAULT_HP)
		update_ui()
	if (!is_enemy && body.is_in_group("enemy_Collider")) || (is_enemy && body.is_in_group("player_Collider")):
		hp = clamp(hp - body.collider_damage, 0, DEFAULT_HP)
		update_ui()
		body.queue_free()
