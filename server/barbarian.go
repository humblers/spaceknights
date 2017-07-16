package main

type Barbarian struct {
    X, Y int
    Hp int
}

func NewBarbarian(x int) *Barbarian {
    return &Barbarian{
        X: x,
        Y: 0,
        Hp: 100,
    }
}
