package main

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
