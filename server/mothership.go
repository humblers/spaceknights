package main

type Mothership struct {
    x, y int
    Hp int
}

func NewMothership() *Mothership {
    return &Mothership{
        x: 0,
        y: 0,
        Hp: 100,
    }
}
