package main

import "log"

const (
    DeckSize = 6
    HandSize = 3
)

type Player struct {
    Hand [HandSize]Card
    Next Card
    Knight *Knight
    Barbarians map[int]*Barbarian
    Elixir int

    deck Deck
    pending [DeckSize - HandSize]Card
    unitCounter int
}

func NewPlayer(knight *Knight, deck Deck) *Player {
    p := Player{
        Knight: knight,
        deck: deck,
        Barbarians: make(map[int]*Barbarian),
    }
    p.deck.Shuffle()
    copy(p.Hand[:], p.deck[:HandSize])
    copy(p.pending[:], p.deck[HandSize:])
    p.Next = p.pending[0]
    return &p
}

func (player *Player) UseCard(index int) {
    card := player.Hand[index]
    switch card {
    case "barbarian":
        player.Barbarians[player.unitCounter] = NewBarbarian(player.Knight.X)
        player.unitCounter++
    default:
        log.Printf("invalid summon name: %v", card)
    }
    player.Hand[index] = player.Next
    for i := 1; i < len(player.pending); i++ {
        player.pending[i - 1] = player.pending[i]
    }
    player.pending[len(player.pending) - 1] = card
    player.Next = player.pending[0]
}
