extends AnimatedSprite

const EFFECT_TIME = 0.3

var wait = rand_range(0, 0.1)
var elapsed = 0

var destination
var size
var speed
var delta

func _ready():
	play(size)

func initialize(starting, _destination, _size):
	destination = _destination
	size = _size
	speed = (starting - destination) / EFFECT_TIME

func update_position(pos):
	if elapsed < wait:
		return pos
	pos.y -= speed * delta
	return pos

func is_finished(_delta):
	delta = _delta
	elapsed += delta
	if elapsed > EFFECT_TIME + wait:
		return true
	return false