package main

import (
    "log"
    "encoding/json"
)

const HandSize = 3

type Player struct {
    Team Team `json:"-"`
    Hand Cards
    Pending Cards `json:"-"`
    Knight *Knight `json:"-"`
    Elixir int
}

func NewPlayer(team Team, deck Cards, knight *Knight) *Player {
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

func (player *Player) Move(x int) {
    switch player.Team {
    case Home:
        player.Knight.X += x
    case Visitor:
        player.Knight.X -= x
    }
}

func (player *Player) UseCard(index int, game *Game) {
    card := player.Hand[index]
    next := player.Pending[0]

    if index >= len(player.Hand) {
        log.Panicf("invalid card index: %v", index)
    }
    if player.Elixir < CostMap[card] {
        log.Panicf("not enough elixir for %v: %v", card, player.Elixir)
    }
    player.Elixir = player.Elixir - CostMap[card]

    player.Hand[index] = next
    for i := 1; i < len(player.Pending); i++ {
        player.Pending[i - 1] = player.Pending[i]
    }
    player.Pending[len(player.Pending) - 1] = card

    switch card {
    case "barbarian":
        game.AddUnit(NewBarbarian(player.Team, player.Knight.X))
    default:
        log.Printf("invalid summon name: %v", card)
    }
}

func (player *Player) IncreaseElixir(amount int) {
    if player.Elixir + amount <= 100 {
        player.Elixir = player.Elixir + amount
    }
}
