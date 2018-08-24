extends Camera2D

var is_shaking = false

# duration : sec
# frequnecy : Hz
# amplitude : pixel
func Shake(duration, frequency, amplitude):
	if is_shaking:
		return
	is_shaking = true
	
	var count = int(frequency * duration)
	var samples = get_samples(count)

	var elapsed = 0
	while(elapsed < duration):
		var curr = int(elapsed * frequency)
		var next = curr + 1
		var t = elapsed / duration
		var shake = samples[curr].linear_interpolate(samples[next], t) * (1 - t)
		offset = shake * amplitude

		yield(get_tree(), "idle_frame")
		elapsed += get_process_delta_time()
	
	is_shaking = false

static func get_samples(count):
	var samples = []
	for i in range(count):
		var x = rand_range(-1.0, 1.0)
		var y = rand_range(-1.0, 1.0)
		samples.append(Vector2(x, y))
	samples.append(Vector2(0, 0))
	return samples
	