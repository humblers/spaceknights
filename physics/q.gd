extends Node

# Q format fixed point number
# https://en.wikipedia.org/wiki/Q_(number_format)

const M = 24
const N = 8
const MAX = (1 << (M + N - 1)) - 1
const MIN = -(MAX + 1)
const ONE = 1 << N
const EPSILON = 1 << N/2

static func Overflow(x):
	return x < MIN or x > MAX

static func Underflow(x, res):
	return x != 0 and res == 0

static func Add(x, y):
	var sum = x + y
	assert(not Overflow(sum))
	return sum
	
static func Sub(x, y):
	var diff = x - y
	assert(not Overflow(diff))
	return diff
	
static func Mul(x, y):
	var temp = x * y
	var res = temp >> N
	assert(not Overflow(res))
	if Underflow(temp, res):
		return EPSILON
	return res
	
static func Div(x, y):
	var res = (x << N) / y
	assert(not Overflow(res))
	if Underflow(x, res):
		return EPSILON
	return res

static func Abs(x):
	return x if x > 0 else -x

static func Pow2(x):
	var res = Mul(x, x)
	assert(not Overflow(res))
	return res

# Reference
# https://github.com/erincatto/Box2D/blob/ff2fa5cb92c0fb7cf357ddfded6152be1629386c/Contributions/Enhancements/FixedPoint/Fixed.h#L434
static func Sqrt(x):
	var m = 0
	var root = 0
	var left = x << N
	m = 1 << (M + N + N) - 2
	while m > 0:
		if (left & -m) > root:
			root += m
			left -= root
			root += m
		root >>= 1
		m >>= 2
	return root

static func Min(x, y):
	return x if x < y else y

static func Max(x, y):
	return x if x > y else y

static func Clamp(x, _min, _max):
	if x < _min:
		return _min
	if x > _max:
		return _max
	return x
	
static func ToInt(q):
	return q / ONE

static func FromInt(i):
	var q = i * ONE
	assert(not Overflow(q))
	return q

static func ToFloat(q):
	return float(q) / ONE

static func FromFloat(f):
	var q = int(f * ONE)
	assert(not Overflow(q))
	return q

static func Test():
	print(ToFloat(Sqrt(FromFloat(2))))
