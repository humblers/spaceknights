package main

import (
    "log"
    "encoding/json"
    "github.com/golang/glog"
)

const HandSize = 3

type Player struct {
    Team Team `json:"-"`
    Hand Cards
    Pending Cards `json:"-"`
    Knight *Unit `json:"-"`
    Energy int
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

func (player *Player) RepairKnight(frame int) (knight *Unit) {
    if player.Knight.Hp <= 0 && player.Knight.RepairFrame == frame {
        knight = player.Knight
        knight.Hp = 100
        knight.Position.X = MapWidth / 2; knight.Position.Y = TileHeight * 1.5
        knight.SpawnFrame = frame + knight.SpawnSpeed
        knight.SpawnStack = 0
        knight.HitFrame = 0
    }
    return
}

func (player *Player) Move(x float64) {
    switch player.Team {
    case Home:
        player.Knight.Position.X += x
    case Visitor:
        player.Knight.Position.X -= x
    }
}

func (player *Player) UseCard(index int, releasePoint float64, game *Game) {
    if player.Knight.Hp <= 0 {
        return
    }
    card := player.Hand[index]
    next := player.Pending[0]

    if index >= len(player.Hand) {
        log.Panicf("invalid card index: %v", index)
    }
    if player.Energy < CostMap[card] {
        glog.Infof("not enough energy for %v: %v", card, player.Energy)
        return
    }
    player.Energy = player.Energy - CostMap[card]

    player.Hand[index] = next
    for i := 1; i < len(player.Pending); i++ {
        player.Pending[i - 1] = player.Pending[i]
    }
    player.Pending[len(player.Pending) - 1] = card

    position := Vector2{player.Knight.Position.X, releasePoint}
    game.AddToWaitingCards(card, player.Team, position)
}

func (player *Player) IncreaseEnergy(amount int) {
    if player.Energy + amount <= 100 {
        player.Energy = player.Energy + amount
    }
}
