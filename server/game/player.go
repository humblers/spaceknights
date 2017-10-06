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

func (player *Player) Move(x float64) {
    switch player.Team {
    case Home:
        player.Knight.Position.X += x
    case Visitor:
        player.Knight.Position.X -= x
    }
}

func (player *Player) UseCard(index int, releasePoint float64, game *Game) {
    card := player.Hand[index]
    next := player.Pending[0]

    if index >= len(player.Hand) {
        log.Panicf("invalid card index: %v", index)
    }
    if player.Energy < CostMap[card] {
        glog.V(0).Infof("not enough energy for %v: %v", card, player.Energy)
        return
    }
    player.Energy = player.Energy - CostMap[card]

    player.Hand[index] = next
    for i := 1; i < len(player.Pending); i++ {
        player.Pending[i - 1] = player.Pending[i]
    }
    player.Pending[len(player.Pending) - 1] = card

    position := Vector2{player.Knight.Position.X, MapHeight - releasePoint}
    switch card {
    case "archers":
        game.AddUnit(NewArcher(player.Team, position, Vector2{1, 0}))
        game.AddUnit(NewArcher(player.Team, position, Vector2{-1, 0}))
    case "barbarians":
        game.AddUnit(NewBarbarian(player.Team, position, Vector2{1, 1}))
        game.AddUnit(NewBarbarian(player.Team, position, Vector2{1, -1}))
        game.AddUnit(NewBarbarian(player.Team, position, Vector2{-1, 1}))
        game.AddUnit(NewBarbarian(player.Team, position, Vector2{-1, -1}))
    case "bomber":
        game.AddUnit(NewBomber(player.Team, position))
    case "cannon":
        game.AddUnit(NewCannon(player.Team, position))
    case "giant":
        game.AddUnit(NewGiant(player.Team, position))
    case "megaminion":
        game.AddUnit(NewMegaminion(player.Team, position))
    case "minipekka":
        game.AddUnit(NewMinipekka(player.Team, position))
    case "musketeer":
        game.AddUnit(NewMusketeer(player.Team, position))
    case "pekka":
        game.AddUnit(NewPekka(player.Team, position))
    case "skeleton":
        game.AddUnit(NewSkeleton(player.Team, position))
    case "speargoblin":
        game.AddUnit(NewSpeargoblin(player.Team, position))
    case "valkyrie":
        game.AddUnit(NewValkyrie(player.Team, position))
    default:
        glog.Warningf("invalid summon name: %v", card)
    }
}

func (player *Player) IncreaseEnergy(amount int) {
    if player.Energy + amount <= 100 {
        player.Energy = player.Energy + amount
    }
}
