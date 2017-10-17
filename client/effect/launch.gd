extends AnimatedSprite

const EFFECT_TIME = 0.4

var elapsed = 0
var speed

func initialize(starting, destination, size):
	speed = (starting - destination) / EFFECT_TIME
	play(size)

func update_position(pos, delta):
	pos.y -= speed * delta
	return pos

func is_finished(delta):
	elapsed += delta
	if elapsed > EFFECT_TIME:
		return true
	return false