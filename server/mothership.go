package main

import "encoding/json"

const MothershipHeight = 110

type Mothership struct {
    Team Team
    Position Vector2
    Layer Layer
}

func NewMothership(team Team) *Mothership {
    m := Mothership{
        Team: team,
        Position: Vector2{
            X: MapWidth / 2,
            Y: MothershipHeight / 2,
        },
        Layer: Ground,
    }
    if team == Home {
        m.Position = m.Position.FlipY()
    }
    return &m
}

func (m *Mothership) Update(game *Game) {
}

func (m *Mothership) MarshalJSON() ([]byte, error) {
    type Alias Mothership
    return json.Marshal(&struct{
        Name string
        *Alias
    }{
        Name: "mothership",
        Alias: (*Alias)(m),
    })
}
