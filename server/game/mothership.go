package main

const MothershipMainHeight = 40
const MothershipSubHeight = 60
const MothershipBaseHeight = 60

func NewMothership(t Team) []*Unit {
    var mothership []*Unit
    main := &Unit{
        Team: t,
        Type: "mothership",
        Name: "maincore",
        Position: Vector2{
            X: MapWidth / 2,
            Y: MothershipBaseHeight + MothershipMainHeight / 2,
        },
        Layer: Ground,
        Hp: 200,
    }
    left := &Unit{
        Team: t,
        Type: "mothership",
        Name: "subcore",
        Position: Vector2{
            X: 70,
            Y: MothershipBaseHeight + MothershipSubHeight / 2,
        },
        Layer: Ground,
        Hp: 100,
    }
    right := &Unit{
        Team: t,
        Type: "mothership",
        Name: "subcore",
        Position: Vector2{
            X: 330,
            Y: MothershipBaseHeight + MothershipSubHeight / 2,
        },
        Layer: Ground,
        Hp: 100,
    }
    base := &Unit{
        Team: t,
        Type: "mothership",
        Name: "base",
        Position: Vector2{
            X: MapWidth / 2,
            Y: MothershipBaseHeight / 2,
        },
        Layer: Ground,
    }
    mothership = append(mothership, main, left, right, base)
    return mothership
}
