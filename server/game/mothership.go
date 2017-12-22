package main

const (
    MothershipMainHeight = 40
    MothershipSubHeight = 60
    MothershipBaseHeight = 10
    MothershipBoosterHeight = 10

    MaincoreScore = 3
    SubcoreScore = 1
)

func NewMothership(t Team) []*Unit {
    main_position_Y :=  float64(MothershipBaseHeight - MothershipBoosterHeight + MothershipMainHeight / 2)
    sub_position_Y := float64(MothershipBaseHeight - MothershipBoosterHeight + MothershipSubHeight / 2)
    base_position_Y := float64(MothershipBaseHeight / 2)
    if t == Home {
        main_position_Y = MapHeight - main_position_Y
        sub_position_Y = MapHeight - sub_position_Y
        base_position_Y = MapHeight - base_position_Y
    }

    var mothership []*Unit
    main := &Unit{
        Team:   t,
        Type:   Building,
        Name:   "maincore",
        Layer:  Ground,
        Hp:     2400,
        InvMass: 0,
        Radius: 20,
        Position: Vector2{
            X: MapWidth / 2,
            Y: main_position_Y,
        },
    }
    left := &Unit{
        Team:   t,
        Type:   Building,
        Name:   "subcore",
        Layer:  Ground,
        Hp:     1400,
        InvMass: 0,
        Radius: 30,
        Position: Vector2{
            X: 70,
            Y: sub_position_Y,
        },
    }
    right := &Unit{
        Team:   t,
        Type:   Building,
        Name:   "subcore",
        Layer:  Ground,
        Hp:     1400,
        InvMass:   0,
        Radius: 30,
        Position: Vector2{
            X: 330,
            Y: sub_position_Y,
        },
    }
    base := &Unit{
        Team:  t,
        Type:  Base,
        Name:  "base",
        Layer: Ground,
        InvMass:  0,
        Position: Vector2{
            X: MapWidth / 2,
            Y: base_position_Y,
        },
    }
    mothership = append(mothership, main, left, right, base)
    return mothership
}
