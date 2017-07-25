package main

import "encoding/json"

const MothershipHeight = 110

type Mothership struct {
    Team Team
    *Position
}

func NewMothership(team Team) *Mothership {
    m := Mothership{
        Team: team,
        Position: &Position{
            X: MapWidth / 2,
            Y: MothershipHeight / 2,
        },
    }
    if team == Home {
        m.FlipY()
    }
    return &m
}

func (m *Mothership) Move() {
}

func (m *Mothership) Attack() {
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
