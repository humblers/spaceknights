extends Node

# Q format fixed point number
# https://en.wikipedia.org/wiki/Q_(number_format)

const M = 16
const N = 16
const MAX = (1 << (M + N - 1)) - 1
const MIN = -(MAX + 1)
const ONE = 1 << N

func CheckRange(x):
	assert(x >= MIN and x <= MAX)

# overflow/underflow check for parameters skipped, only output value validated
func Add(x, y):
#	CheckRange(x)
#	CheckRange(y)
	var sum = x + y
	CheckRange(sum)
	return sum
	
func Sub(x, y):
#	CheckRange(x)
#	CheckRange(y)
	var diff = x - y
	CheckRange(diff)
	return diff
	
func Mul(x, y):
#	CheckRange(x)
#	CheckRange(y)
	var res = (x * y) >> N
	CheckRange(res)
	return res
	
func Div(x, y):
#	CheckRange(x)
#	CheckRange(y)
	var res = (x << N) / y
	CheckRange(res)
	return res

func Abs(x):
	return x if x > 0 else -x

func Pow2(x):
#	CheckRange(x)
	var res = Mul(x, x)
	CheckRange(res)
	return res

# Reference
# https://github.com/erincatto/Box2D/blob/ff2fa5cb92c0fb7cf357ddfded6152be1629386c/Contributions/Enhancements/FixedPoint/Fixed.h#L434
func Sqrt(x):
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

func Min(x, y):
	return x if x < y else y

func Max(x, y):
	return x if x > y else y

func Clamp(x, _min, _max):
	if x < _min:
		return _min
	if x > _max:
		return _max
	return x
	
func ToInt(q):
	return q / ONE

func FromInt(i):
	var q = i * ONE
	CheckRange(q)
	return q

func ToFloat(q):
	return float(q) / ONE

func FromFloat(f):
	var q = int(f * ONE)
	CheckRange(q)
	return q

func Test():
	print(ToFloat(Sqrt(FromFloat(2))))
