package main

import "math"

const (
    MapWidth = 400
    MapHeight = 620
)

type Vector2 struct {
    X, Y float64
}

func (v Vector2) FlipY() Vector2 {
    v.Y = MapHeight - v.Y
    return v
}

func (a Vector2) Minus(b Vector2) Vector2 {
    return Vector2{
        X: a.X - b.X,
        Y: a.Y - b.Y,
    }
}

func (v Vector2) Length() float64 {
    return math.Sqrt(v.X * v.X + v.Y * v.Y)
}
