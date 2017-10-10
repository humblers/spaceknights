extends AnimatedSprite

const EFFECT_TIME = 0.3

var wait = rand_range(0, 0.1)
var elapsed = 0

var speed

func initialize(starting, destination, size):
	speed = (starting - destination) / EFFECT_TIME
	play(size)

func update_position(pos, delta):
	if elapsed < wait:
		return pos
	pos.y -= speed * delta
	return pos

func is_finished(delta):
	elapsed += delta
	if elapsed > EFFECT_TIME + wait:
		return true
	return false