package main

import "math"

type Vector2 struct {
    X, Y float64
}

func (a Vector2) Plus(b Vector2) Vector2 {
    return Vector2{
        X: a.X + b.X,
        Y: a.Y + b.Y,
    }
}

func (a Vector2) Minus(b Vector2) Vector2 {
    return Vector2{
        X: a.X - b.X,
        Y: a.Y - b.Y,
    }
}

func (v Vector2) Multiply(c float64) Vector2 {
    return Vector2{
        X: v.X * c,
        Y: v.Y * c,
    }
}

func (v Vector2) Length() float64 {
    return math.Sqrt(v.X * v.X + v.Y * v.Y)
}

func (v Vector2) Normalize() Vector2 {
    l := v.Length()
    return Vector2{
        X: v.X / l,
        Y: v.Y / l,
    }
}

func (a Vector2) Cross(b Vector2) float64 {
    return a.X * b.Y - a.Y * b.X
}
