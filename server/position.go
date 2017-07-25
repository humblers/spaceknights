package main

const (
    MapWidth = 400
    MapHeight = 620
)

type Position struct {
    X, Y int
}

func (p *Position) FlipY() {
    p.Y = MapHeight - p.Y
}
