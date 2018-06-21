extends Node

# Q format fixed point number
# https://en.wikipedia.org/wiki/Q_(number_format)

# [ATTENTION]
# fixed point number assumes godot engine uses int64_t 
# as the internal respresentation of Variant::INT
# https://github.com/godotengine/godot/commit/13cdccf23ba639d7a30a590698cfd36ee558c794

const m = 16
const n = 16
const scale = 1 << n
const max_ = (1 << (m + n - 1)) - 1
const min_ = -(max_ + 1)
const epsilon = 1

const One = scale
const Two = One << 1

static func FromInt(i):
	return saturated(i * scale)

static func ToInt(s):
	return s / scale

static func FromFloat(f):
	var val = int(saturated(f * scale))
	if f != 0 && val == 0:
		#print("underflow")
		if f < 0:
			return -epsilon
		return epsilon
	return val

static func ToFloat(s):
	return float(s) / scale

static func Add(x, y):
	return saturated(x + y)

static func Sub(x, y):
	return saturated(x - y)
	
static func Mul(x, y):
	var temp = x * y
	var res = temp / scale
	if underflow(temp, res):
		if temp < 0:
			return -epsilon
		return epsilon
	return saturated(res)
	
static func Div(x, y):
	var temp = x * scale
	var res = temp / y
	if underflow(temp, res):
		if (x > 0 and y < 0) or (x < 0 and y > 0):
			return -epsilon
		return epsilon
	return saturated(res)

static func Abs(x):
	return x if x > 0 else saturated(-x)

static func Clamp(x, _min, _max):
	if x < _min:
		return _min
	if x > _max:
		return _max
	return x

# https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Binary_numeral_system_(base_2)
static func Sqrt(x):
	x <<= n
	var res = 0
	var bit = 1 << (m + n + n - 2)
	while bit > x:
		bit >>= 2
	while bit != 0:
		if x >= res + bit:
			x -= res + bit
			res = (res >> 1) + bit
		else:
			res >>= 1
		bit >>= 2
	return res

static func saturated(x):
	var res = Clamp(x, min_, max_)
	if res != x:
		print("overflow")
	return res

static func underflow(_in, out):
	var b = (_in != 0 and out == 0)
#	if b:
#		print("underflow")
	return b

static func Min(x, y):
	return x if x < y else y

static func Max(x, y):
	return x if x > y else y
