package main

import "encoding/json"

type Barbarian struct {
    Team Team
    Position Vector2
    Layer Layer
    velocity Vector2
}

func NewBarbarian(team Team, x float64) *Barbarian {
    b := Barbarian{
        Team: team,
        Position: Vector2{
            X: x,
            Y: 200,
        },
        Layer: Ground,
    }
    if team == Home {
        b.Position = b.Position.FlipY()
    }
    return &b
}

func (b *Barbarian) Update(game *Game) {
    // Scan enemies
    // Follow flow vector
    // Add steering behavior (seperation + obstacle avoidance)
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
