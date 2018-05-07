extends Node

# Q format fixed point number
# https://en.wikipedia.org/wiki/Q_(number_format)

const M = 24
const N = 8
const MAX = (1 << (M + N - 1)) - 1
const MIN = -(MAX + 1)
const ONE = 1 << N
const EPSILON = 1

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
	return Mul(x, x)

# https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Binary_numeral_system_(base_2)
static func Sqrt(num):
	var res = 0
	num <<= N
	var bit = 1 << (M + N + N) - 2
	while bit > num:
		bit >>= 2
	while bit != 0:
		if num >= res + bit:
			num -= res + bit
			res = (res >> 1) + bit
		else:
			res >>= 1
		bit >>= 2
	return res
	
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
