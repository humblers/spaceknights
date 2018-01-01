package main

import (
    "encoding/json"
    "github.com/golang/glog"
)

const MaxEnergy = 10000
const EnergyPerFrame = 200
const HandSize = 3

type Player struct {
    Team Team
    Hand Cards
    Pending Cards `json:"-"`
    Knights []*Unit `json:"-"`
    Energy int
    Movements []*Movement `json:"-"`
}

type Movement struct {
    PositionX float64
    Frame int
}
type Players map[string]*Player

func (players Players) Filter(f func(*Player) bool) Players {
    filtered := make(map[string]*Player)
    for id, player := range players {
        if f(player) {
            filtered[id] = player
        }
    }
    return filtered
}

func NewPlayer(team Team, deck Cards, knights []*Unit) *Player {
    deck.Shuffle()
    return &Player{
        Team: team,
        Hand: deck[:HandSize],
        Pending: deck[HandSize:],
        Knights: knights,
    }
}

func (p *Player) MarshalJSON() ([]byte, error) {
    type Alias Player
    return json.Marshal(&struct{
        Next Card
        *Alias
    }{
        Next: p.Pending[0],
        Alias: (*Alias)(p),
    })
}

func (player *Player) Update() {
    player.IncreaseEnergy(EnergyPerFrame)
}

func (player *Player) Move(input Input) {
    for _, knight := range player.Knights {
        if knight.Id != input.Move {
            continue
        }
        if knight.Position != knight.Destination {
            continue
        }
        knight.Destination = input.Position
        switch player.Team {
        case Home:
            knight.Destination = knight.Destination.Clamp(0, MapWidth, CenterY + TileHeight, MapHeight)
        case Visitor:
            knight.Destination.X = MapWidth - knight.Destination.X
            knight.Destination.Y = MapHeight - knight.Destination.Y
            knight.Destination = knight.Destination.Clamp(0, MapWidth, 0, CenterY - TileHeight)
        }
    }

}

func (player *Player) UseCard(input Input, game *Game) {
    index := input.Use - 1
    if index >= len(player.Hand) {
        glog.Errorf("invalid card index(%v)", index)
        return
    }
    card := player.Hand[index]

    if player.Energy < CostMap[card] {
        glog.Infof("not enough energy for %v: %v", card, player.Energy)
        return
    }

    player.Hand[index] = player.Pending[0]
    for i := 1; i < len(player.Pending); i++ {
        player.Pending[i - 1] = player.Pending[i]
    }
    player.Pending[len(player.Pending) - 1] = card

    player.Energy = player.Energy - CostMap[card]
    game.Stats[player.Team].EnergyUsed += CostMap[card]

    if player.Team == Visitor {
        input.Position.X = MapWidth - input.Position.X
        input.Position.Y = MapHeight - input.Position.Y
    }
    game.AddToWaitingCards(card, input.Position, player)
}

func (player *Player) IncreaseEnergy(amount int) {
    if player.Energy += amount; player.Energy > MaxEnergy {
        player.Energy = MaxEnergy
    }
}
