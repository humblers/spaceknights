package fixed

import (
	"math"
	"testing"
)

func TestFromInt(t *testing.T) {
	cases := []struct {
		x    int
		want Scalar
	}{
		{1, One},
		{1 << m, max},        // saturation
		{-(1 << m) - 1, min}, // saturation
	}
	for _, c := range cases {
		got := FromInt(c.x)
		if got != c.want {
			t.Errorf("FromInt(%v) == %v, want %v", c.x, got, c.want)
		}
	}
}

func TestScalar_ToInt(t *testing.T) {
	cases := []struct {
		x    Scalar
		want int
	}{
		{One, 1},
	}
	for _, c := range cases {
		got := c.x.ToInt()
		if got != c.want {
			t.Errorf("%v.ToInt() == %v, want %v", c.x, got, c.want)
		}
	}
}

func TestFromFloat(t *testing.T) {
	cases := []struct {
		x    float64
		want Scalar
	}{
		{1.0, One},
		{float64(1 << m), max},                 // saturation
		{float64(-(1 << m) - 1), min},          // saturation
		{float64(math.Pow(0.5, n+1)), epsilon}, // underflow
	}
	for _, c := range cases {
		got := FromFloat(c.x)
		if got != c.want {
			t.Errorf("FromFloat(%v) == %v, want %v", c.x, got, c.want)
		}
	}
}

func TestScalar_ToFloat(t *testing.T) {
	cases := []struct {
		x    Scalar
		want float64
	}{
		{One, 1.0},
	}
	for _, c := range cases {
		got := c.x.ToFloat()
		if got != c.want {
			t.Errorf("%v.ToFloat() == %v, want %v", c.x, got, c.want)
		}
	}
}

func TestScalar_Add(t *testing.T) {
	cases := []struct {
		x, y, want Scalar
	}{
		{One, One, One * 2},
		{max, epsilon, max},  // saturation
		{min, -epsilon, min}, // saturation
	}
	for _, c := range cases {
		got := c.x.Add(c.y)
		if got != c.want {
			t.Errorf("%v.Add(%v) == %v, want %v", c.x, c.y, got, c.want)
		}
	}
}

func TestScalar_Sub(t *testing.T) {
	cases := []struct {
		x, y, want Scalar
	}{
		{One, One, 0},
		{max, -epsilon, max}, // saturation
		{min, epsilon, min},  // saturation
	}
	for _, c := range cases {
		got := c.x.Sub(c.y)
		if got != c.want {
			t.Errorf("%v.Sub(%v) == %v, want %v", c.x, c.y, got, c.want)
		}
	}
}

func TestScalar_Mul(t *testing.T) {
	cases := []struct {
		x, y, want Scalar
	}{
		{One, One, One},
		{max, One + epsilon, max},           // saturation
		{min, One + epsilon, min},           // saturation
		{epsilon, One - epsilon, epsilon},   // underflow
		{-epsilon, One - epsilon, -epsilon}, // underflow
	}
	for _, c := range cases {
		got := c.x.Mul(c.y)
		if got != c.want {
			t.Errorf("%v.Mul(%v) == %v, want %v", c.x, c.y, got, c.want)
		}
	}
}

func TestScalar_Div(t *testing.T) {
	cases := []struct {
		x, y, want Scalar
	}{
		{One, One, One},
		{max, One - epsilon, max},           // saturation
		{min, One - epsilon, min},           // saturation
		{epsilon, One + epsilon, epsilon},   // underflow
		{-epsilon, One + epsilon, -epsilon}, // underflow
	}
	for _, c := range cases {
		got := c.x.Div(c.y)
		if got != c.want {
			t.Errorf("%v.Div(%v) == %v, want %v", c.x, c.y, got, c.want)
		}
	}
}

func TestScalar_Abs(t *testing.T) {
	cases := []struct {
		x, want Scalar
	}{
		{One, One},
		{-One, One},
		{min, max}, // saturation
	}
	for _, c := range cases {
		got := c.x.Abs()
		if got != c.want {
			t.Errorf("%v.Abs() == %v, want %v", c.x, got, c.want)
		}
	}
}

func TestScalar_Clamp(t *testing.T) {
	cases := []struct {
		x, min, max, want Scalar
	}{
		{One, One * 2, One * 3, One * 2},
		{One * 3, One, One * 2, One * 2},
		{One * 2, One, One * 3, One * 2},
	}
	for _, c := range cases {
		got := c.x.Clamp(c.min, c.max)
		if got != c.want {
			t.Errorf("%v.Clamp(%v, %v) == %v, want %v", c.x, c.min, c.max, got, c.want)
		}
	}
}

func TestScalar_Sqrt(t *testing.T) {
	cases := []struct {
		x, want Scalar
	}{
		{One, One},
		{One * 4, One * 2},
	}
	for _, c := range cases {
		got := c.x.Sqrt()
		if got != c.want {
			t.Errorf("%v.Sqrt() == %v, want %v", c.x, got, c.want)
		}
	}
}

func TestMin(t *testing.T) {
	cases := []struct {
		x, y, want Scalar
	}{
		{One, One * 2, One},
	}
	for _, c := range cases {
		got := Min(c.x, c.y)
		if got != c.want {
			t.Errorf("Min(%v, %v) == %v, want %v", c.x, c.y, got, c.want)
		}
	}
}

func TestMax(t *testing.T) {
	cases := []struct {
		x, y, want Scalar
	}{
		{One, One * 2, One * 2},
	}
	for _, c := range cases {
		got := Max(c.x, c.y)
		if got != c.want {
			t.Errorf("Max(%v, %v) == %v, want %v", c.x, c.y, got, c.want)
		}
	}
}
