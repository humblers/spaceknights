extends AnimatedSprite

const EFFECT_TIME = 0.3

var wait = rand_range(0, 0.1)
var elapsed = 0
var speed

var unit_node
var destination
var size

signal launch_finished

func _ready():
	speed = (510 - destination) / EFFECT_TIME
	play(size)
	set_process(true)

func _process(delta):
	elapsed += delta
	if elapsed < wait:
		return
	var pos = unit_node.get_pos()
	pos.y -= speed * delta
	unit_node.set_pos(pos)
	if elapsed > EFFECT_TIME + wait:
		emit_signal("launch_finished")
		queue_free()

func initialize(_unit_node, _destination, _size):
	unit_node = _unit_node
	destination = _destination
	size = _size