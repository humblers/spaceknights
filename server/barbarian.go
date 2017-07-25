package main

import "encoding/json"

type Barbarian struct {
    Team Team
    *Position
}

func NewBarbarian(team Team, x int) *Barbarian {
    b := Barbarian{
        Team: team,
        Position: &Position{
            X: x,
            Y: 200,
        },
    }
    if team == Home {
        b.FlipY()
    }
    return &b
}

func (b *Barbarian) Move() {
}

func (b *Barbarian) Attack() {
}

func (b *Barbarian) MarshalJSON() ([]byte, error) {
    type Alias Barbarian
    return json.Marshal(&struct{
        Name string
        *Alias
    }{
        Name: "barbarian",
        Alias: (*Alias)(b),
    })
}
