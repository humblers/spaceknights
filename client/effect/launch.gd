extends AnimatedSprite

var elapsed = 0
var speed

func initialize(starting, destination, size):
	speed = (starting - destination) / global.UNIT_LAUNCH_TIME
	play(size)

func update_position(pos, delta):
	pos.y -= speed * delta
	return pos

func is_finished(delta):
	elapsed += delta
	if elapsed > global.UNIT_LAUNCH_TIME:
		return true
	return false