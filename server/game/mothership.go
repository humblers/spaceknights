package main

const (
    MothershipMainHeight = 40
    MothershipSubHeight = 60
    MothershipBaseHeight = 60

    MaincoreScore = 3
    SubcoreScore = 1
)

func NewMothership(t Team) []*Unit {
    var mothership []*Unit
    main := &Unit{
        Team:   t,
        Type:   Building,
        Name:   "maincore",
        Layer:  Ground,
        Hp:     2400,
        Mass:   100,
        Radius: 20,
        Position: Vector2{
            X: MapWidth / 2,
            Y: MothershipBaseHeight + MothershipMainHeight / 2,
        },
    }
    left := &Unit{
        Team:   t,
        Type:   Building,
        Name:   "subcore",
        Layer:  Ground,
        Hp:     1400,
        Mass:   100,
        Radius: 30,
        Position: Vector2{
            X: 70,
            Y: MothershipBaseHeight + MothershipSubHeight / 2,
        },
    }
    right := &Unit{
        Team:   t,
        Type:   Building,
        Name:   "subcore",
        Layer:  Ground,
        Hp:     1400,
        Mass:   100,
        Radius: 30,
        Position: Vector2{
            X: 330,
            Y: MothershipBaseHeight + MothershipSubHeight / 2,
        },
    }
    base := &Unit{
        Team:  t,
        Type:  Base,
        Name:  "base",
        Layer: Ground,
        Mass:  100,
        Position: Vector2{
            X: MapWidth / 2,
            Y: MothershipBaseHeight / 2,
        },
    }
    mothership = append(mothership, main, left, right, base)
    return mothership
}
