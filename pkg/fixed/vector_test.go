package fixed

import (
	"testing"
)

func TestVector_Add(t *testing.T) {
	cases := []struct {
		x, y, want Vector
	}{
		{Vector{One, 0}, Vector{0, One}, Vector{One, One}},
	}
	for _, c := range cases {
		got := c.x.Add(c.y)
		if got != c.want {
			t.Errorf("%v.Add(%v) == %v, want %v", c.x, c.y, got, c.want)
		}
	}
}

func TestVector_Sub(t *testing.T) {
	cases := []struct {
		x, y, want Vector
	}{
		{Vector{One, One}, Vector{0, One}, Vector{One, 0}},
	}
	for _, c := range cases {
		got := c.x.Sub(c.y)
		if got != c.want {
			t.Errorf("%v.Sub(%v) == %v, want %v", c.x, c.y, got, c.want)
		}
	}
}

func TestVector_Mul(t *testing.T) {
	cases := []struct {
		x    Vector
		s    Scalar
		want Vector
	}{
		{Vector{One, One}, One * 2, Vector{One * 2, One * 2}},
	}
	for _, c := range cases {
		got := c.x.Mul(c.s)
		if got != c.want {
			t.Errorf("%v.Mul(%v) == %v, want %v", c.x, c.s, got, c.want)
		}
	}
}

func TestVector_Div(t *testing.T) {
	cases := []struct {
		x    Vector
		s    Scalar
		want Vector
	}{
		{Vector{One * 2, One * 2}, One * 2, Vector{One, One}},
	}
	for _, c := range cases {
		got := c.x.Div(c.s)
		if got != c.want {
			t.Errorf("%v.Div(%v) == %v, want %v", c.x, c.s, got, c.want)
		}
	}
}

func TestVector_Dot(t *testing.T) {
	cases := []struct {
		x, y Vector
		want Scalar
	}{
		{Vector{One, 0}, Vector{0, One}, 0},
	}
	for _, c := range cases {
		got := c.x.Dot(c.y)
		if got != c.want {
			t.Errorf("%v.Dot(%v) == %v, want %v", c.x, c.y, got, c.want)
		}
	}
}

func TestVector_Cross(t *testing.T) {
	cases := []struct {
		x, y Vector
		want Scalar
	}{
		{Vector{One, 0}, Vector{0, One}, One},
	}
	for _, c := range cases {
		got := c.x.Cross(c.y)
		if got != c.want {
			t.Errorf("%v.Cross(%v) == %v, want %v", c.x, c.y, got, c.want)
		}
	}
}

func TestVector_LengthSquared(t *testing.T) {
	cases := []struct {
		x    Vector
		want Scalar
	}{
		{Vector{One * 3, One * 4}, One * 25},
	}
	for _, c := range cases {
		got := c.x.LengthSquared()
		if got != c.want {
			t.Errorf("%v.LengthSquared() == %v, want %v", c.x, got, c.want)
		}
	}
}

func TestVector_Length(t *testing.T) {
	cases := []struct {
		x    Vector
		want Scalar
	}{
		{Vector{One * 3, One * 4}, One * 5},
	}
	for _, c := range cases {
		got := c.x.Length()
		if got != c.want {
			t.Errorf("%v.Length() == %v, want %v", c.x, got, c.want)
		}
	}
}

func TestVector_Normalized(t *testing.T) {
	cases := []struct {
		x, want Vector
	}{
		{Vector{One / 2, 0}, Vector{One, 0}},
		{Vector{One * 2, 0}, Vector{One, 0}},
	}
	for _, c := range cases {
		got := c.x.Normalized()
		if got != c.want {
			t.Errorf("%v.Normalized() == %v, want %v", c.x, got, c.want)
		}
	}
}

func TestVector_Truncated(t *testing.T) {
	cases := []struct {
		x    Vector
		s    Scalar
		want Vector
	}{
		{Vector{One / 2, 0}, One, Vector{One / 2, 0}},
		{Vector{One * 2, 0}, One, Vector{One, 0}},
	}
	for _, c := range cases {
		got := c.x.Truncated(c.s)
		if got != c.want {
			t.Errorf("%v.Truncated(%v) == %v, want %v", c.x, c.s, got, c.want)
		}
	}
}
