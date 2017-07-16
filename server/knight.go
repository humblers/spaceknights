package main

type Knight struct {
    Type string
    X, Y int
    Hp int
}

func NewKnight(t string) *Knight {
    return &Knight{
        Type: t,
        X: 0,
        Y: 0,
        Hp: 100,
    }
}
