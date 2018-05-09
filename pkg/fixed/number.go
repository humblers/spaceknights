// Package fixed provide primitives for fixed point math
package fixed

import (
	"log"
	"os"
)

import "fmt"

const (
	m              = 16
	n              = 16
	scale          = 1 << n
	max     Number = (1 << (m + n - 1)) - 1
	min     Number = -(max + 1)
	epsilon Number = 1
)

const (
	One       Number = scale
	Tenth     Number = One >> 1
	Hundredth Number = Tenth >> 1
)

var logger = log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)

func SetLogger(l *log.Logger) {
	logger = l
}

// Number represents a single fixed point number in Q-format: https://en.wikipedia.org/wiki/Q_(number_format)
type Number int64

func (x Number) String() string {
	return fmt.Sprint(x.ToFloat())
}

func FromInt(x int) Number {
	return Number(x * scale).saturated()
}

func (x Number) ToInt() int {
	return int(x / scale)
}

// FromFloat returns the fixed value from a float x.
// Note that the result of this function is NOT deterministic.
func FromFloat(x float64) Number {
	val := Number(x * scale).saturated()
	if x != 0 && val == 0 {
		logger.Println("underflow")
		if x < 0 {
			return -epsilon
		}
		return epsilon
	}
	return val
}

// ToFloat returns the float value from a fixed x.
// Note that the result of this function is NOT deterministic.
func (x Number) ToFloat() float64 {
	return float64(x) / float64(scale)
}

func (x Number) Add(y Number) Number {
	return (x + y).saturated()
}

func (x Number) Sub(y Number) Number {
	return (x - y).saturated()
}

func (x Number) Mul(y Number) Number {
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

func (x Number) Div(y Number) Number {
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

func (x Number) Abs() Number {
	if x < 0 {
		return (-x).saturated()
	}
	return x
}

func (x Number) Clamp(min, max Number) Number {
	if x < min {
		return min
	}
	if x > max {
		return max
	}
	return x
}

// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Binary_numeral_system_(base_2)
func (x Number) Sqrt() Number {
	x <<= n
	var res Number = 0
	var bit Number = 1 << (m + n + n - 2)
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

func (x Number) saturated() Number {
	res := x.Clamp(min, max)
	if res != x {
		logger.Println("overflow")
	}
	return res
}

func underflow(in Number, out Number) bool {
	b := (in != 0 && out == 0)
	if b {
		logger.Println("underflow")
	}
	return b
}

func Min(x, y Number) Number {
	if x < y {
		return x
	}
	return y
}

func Max(x, y Number) Number {
	if x > y {
		return x
	}
	return y
}
