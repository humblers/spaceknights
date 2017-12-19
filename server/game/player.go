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
    Knight *Unit `json:"-"`
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

func NewPlayer(team Team, deck Cards, knight *Unit) *Player {
    deck.Shuffle()
    return &Player{
        Team: team,
        Hand: deck[:HandSize],
        Pending: deck[HandSize:],
        Knight: knight,
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
    offset := input.Position
    knight := player.Knight
    switch player.Team {
    case Home:
        knight.Position = knight.Position.Plus(offset)
        knight.Position = knight.Position.Clamp(0, MapWidth, CenterY + TileHeight, MapHeight)
    case Visitor:
        knight.Position = knight.Position.Minus(offset)
        knight.Position = knight.Position.Clamp(0, MapWidth, 0, CenterY - TileHeight)
    }
}

func (player *Player) UseCard(input Input, game *Game) {
    var card Card = "moveknight"
    index := input.Use - 1
    if index < len(player.Hand) {
        card = player.Hand[index]
    }

    if player.Energy < CostMap[card] {
        glog.Infof("not enough energy for %v: %v", card, player.Energy)
        return
    }

    if card == "moveknight" && player.Knight.IsDead() {
        return
    }
    if card != "moveknight" {
        next := player.Pending[0]

        player.Hand[index] = next
        for i := 1; i < len(player.Pending); i++ {
            player.Pending[i - 1] = player.Pending[i]
        }
        player.Pending[len(player.Pending) - 1] = card
    }

    player.Energy = player.Energy - CostMap[card]
    game.Stats[player.Team].EnergyUsed += CostMap[card]

    position := player.Knight.Position
    game.AddToWaitingCards(card, position, player)
}

func (player *Player) IncreaseEnergy(amount int) {
    if player.Energy += amount; player.Energy > MaxEnergy {
        player.Energy = MaxEnergy
    }
}
