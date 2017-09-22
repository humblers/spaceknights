extends Area2D

var target_id
var target_pos
var hitafter

onready var elapsed = 0

func _ready():
	pass

func _process(delta):
	elapsed += delta
	var remain = hitafter - elapsed
	if remain <= 0:
		queue_free()
		return
	var pos = get_pos()
	set_rot(target_pos.angle_to_point(pos))
	var speed = pos.distance_to(target_pos) / remain * delta
	set_pos(pos + (target_pos - pos).normalized() * speed)

func initialize(_pos, _targetid, _target, _hitafter):
	set_pos(_pos)
	target_id = _targetid
	hitafter = float(_hitafter) / 10
	_target.connect("send_posistion", self, "update_target_pos")
	target_pos = _target.get_pos()
	set_layer_mask(1 if _target.team == "Home" else 0)
	set_collision_mask(0 if _target.team == "Home" else 1)
	connect("area_enter", self, "on_area_enter")
	set_process(true)

func update_target_pos(pos):
	target_pos = pos

func on_area_enter(area):
	if target_id == area.get_name():
		area.damage_modulate()
		queue_free()