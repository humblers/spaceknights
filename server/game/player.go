package main

import (
    "encoding/json"
    "github.com/golang/glog"
)

const MinEnergy = 0
const MaxEnergy = 10000
const EnergyPerFrame = 100
const KnightShotCycle = 40
const HandSize = 3

type Player struct {
    Team Team `json:"-"`
    Hand Cards
    Pending Cards `json:"-"`
    Knight *Unit `json:"-"`
    KnightIdleTo int
    Energy int
}

func NewPlayer(team Team, deck Cards, knight *Unit) *Player {
    deck.Shuffle()
    hand := append(Cards{}, deck[:HandSize]...)
    hand = append(hand, "shoot")
    return &Player{
        Team: team,
        Hand: hand,
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

func (player *Player) SetState(input Input, game *Game) {
    if player.KnightIdleTo < game.Frame {
        player.Knight.State = input.State
        player.Knight.Position = input.Position
    }
}

func (player *Player) UseCard(input Input, game *Game) {
    index := input.Use - 1
    if index >= len(player.Hand) {
        glog.Fatalf("invalid card index: %v", index)
        return
    }

    card := player.Hand[index]
    if player.Energy < CostMap[card] {
        glog.Infof("not enough energy for %v: %v", card, player.Energy)
        return
    }
    if card == "shoot" {
        if player.KnightIdleTo > game.Frame {
            glog.Infof("shoot card refused. until: %v, cur: %v", player.KnightIdleTo, game.Frame)
            return
        }
        player.KnightIdleTo = game.Frame + ActivateAfter + KnightShotCycle
        player.Knight.State = Prepare
    } else {
        player.Hand[index] = player.Pending[0]
        for i := 1; i < len(player.Pending); i++ {
            player.Pending[i - 1] = player.Pending[i]
        }
        player.Pending[len(player.Pending) - 1] = card
    }
    player.OperateEnergy(-CostMap[card])
    game.Stats[player.Team].EnergyUsed += CostMap[card]

    position := input.Position
    game.AddToWaitingCards(card, position, player)
}

func (player *Player) OperateEnergy(amount int) {
    player.Energy += amount
    if player.Energy >= MaxEnergy {
        player.Energy = MaxEnergy
    }
    if player.Energy <= MinEnergy {
        player.Energy = MinEnergy
    }
}
