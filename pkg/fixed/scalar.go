// Package fixed provide primitives for fixed point math
package fixed

import "log"
import "os"

const (
	m              = 16
	n              = 16
	scale          = 1 << n
	max     Scalar = (1 << (m + n - 1)) - 1
	min     Scalar = -(max + 1)
	epsilon Scalar = 1

	One Scalar = scale
	Two Scalar = One << 1
)

var logger = log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)

func SetLogger(l *log.Logger) {
	logger = l
}

// Scalar represents a single fixed point number in Q-format: https://en.wikipedia.org/wiki/Q_(number_format)
type Scalar int64

func FromInt(x int) Scalar {
	return Scalar(x * scale).saturated()
}

func (x Scalar) ToInt() int {
	return int(x / scale)
}

// FromFloat returns the fixed value from a float x.
// Note that the result of this function is NOT deterministic.
func FromFloat(x float64) Scalar {
	val := Scalar(x * scale).saturated()
	if x != 0 && val == 0 {
		//logger.Println("underflow")
		if x < 0 {
			return -epsilon
		}
		return epsilon
	}
	return val
}

// ToFloat returns the float value from a fixed x.
// Note that the result of this function is NOT deterministic.
func (x Scalar) ToFloat() float64 {
	return float64(x) / float64(scale)
}

func (x Scalar) Add(y Scalar) Scalar {
	return (x + y).saturated()
}

func (x Scalar) Sub(y Scalar) Scalar {
	return (x - y).saturated()
}

func (x Scalar) Mul(y Scalar) Scalar {
	temp := x * y
	res := temp / scale
	if underflow(temp, res) {
		if temp < 0 {
			return -epsilon
		}
		return epsilon
	}
	return res.saturated()
}

func (x Scalar) Div(y Scalar) Scalar {
	temp := x * scale
	res := temp / y
	if underflow(temp, res) {
		if (x > 0 && y < 0) || (x < 0 && y > 0) {
			return -epsilon
		}
		return epsilon
	}
	return res.saturated()
}

func (x Scalar) Abs() Scalar {
	if x < 0 {
		return (-x).saturated()
	}
	return x
}

func (x Scalar) Clamp(min, max Scalar) Scalar {
	if x < min {
		return min
	}
	if x > max {
		return max
	}
	return x
}

// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Binary_numeral_system_(base_2)
func (x Scalar) Sqrt() Scalar {
	x <<= n
	var res Scalar = 0
	var bit Scalar = 1 << (m + n + n - 2)
	for bit > x {
		bit >>= 2
	}
	for bit != 0 {
		if x >= res+bit {
			x -= res + bit
			res = (res >> 1) + bit
		} else {
			res >>= 1
		}
		bit >>= 2
	}
	return res
}

func (x Scalar) saturated() Scalar {
	res := x.Clamp(min, max)
	if res != x {
		logger.Println("overflow")
	}
	return res
}

func underflow(in Scalar, out Scalar) bool {
	b := (in != 0 && out == 0)
	if b {
		//logger.Println("underflow")
	}
	return b
}

func Min(x, y Scalar) Scalar {
	if x < y {
		return x
	}
	return y
}

func Max(x, y Scalar) Scalar {
	if x > y {
		return x
	}
	return y
}
