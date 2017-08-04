package main

const MothershipHeight = 110

func NewMothership(t Team) *Unit {
    p := Vector2{
        X: MapWidth / 2,
        Y: MothershipHeight / 2,
    }
    return &Unit{
        Team: t,
        Name: "mothership",
        Position: p,
        Layer: Ground,
        Hp: 500,
        Radius: 45,
    }
}
