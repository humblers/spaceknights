package main

import (
    "encoding/json"
    "github.com/golang/glog"
)

const MinEnergy = 0
const MaxEnergy = 10000
const EnergyPerFrame = 200
const MovingCost = 60
const ShotCost = 550
const HandSize = 3

type Player struct {
    Team Team `json:"-"`
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

func NewPlayer(team Team, deck Cards, knight *Unit) *Player {
    deck.Shuffle()
    hand := append(Cards{}, deck[:HandSize]...)
    hand = append(hand, "moveknight", "shoot")
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

func (player *Player) UpdateKnight() {
    knight := player.Knight
    knight.ClearEvents()
    if knight.IsDead() {
        if knight.RepairFrame != knight.Game.Frame {
            return
        }
        knight.Hp = 500
        knight.Position = Vector2{MapWidth / 2, MothershipBaseHeight + MothershipMainHeight + TileHeight * 1.5}
        knight.Destination = knight.Position
        knight.SpawnStack = 0
        knight.HitFrame = 0
        knight.Game.AddUnit(knight)
    }
    if knight.IsAttacking() {
        knight.HandleAttack()
    } else {
        if !knight.HasTarget() || !knight.WithinRange(knight.Target) {
            var filter = func(other *Unit) bool {
                return knight.WithinRange(other)
            }
            knight.Target = knight.FindNearestTarget(filter)
        }
        if knight.Target != nil {
            knight.StartAttack()
        }
    }
    if player.Energy >= ShotCost {
        if knight.HandleSpawn() {
            player.OperateEnergy(-ShotCost)
            knight.Game.Stats[player.Team].EnergyUsed += ShotCost
        }
    } else {
        knight.SetSpawn(false)
    }
    if player.Energy >= MovingCost && knight.Position != knight.Destination {
        player.OperateEnergy(-MovingCost)
        knight.Game.Stats[player.Team].EnergyUsed += MovingCost
        knight.Velocity = knight.Destination.Minus(knight.Position).Truncate(knight.Speed)
    } else {
        knight.Velocity = Vector2{0, 0}
    }
}

func (player *Player) UseCard(input Input, game *Game) {
    index := input.Use.Index - 1
    if index >= len(player.Hand) {
        glog.Fatalf("invalid card index: %v", index)
        return
    }
    card := player.Hand[index]

    if player.Energy < CostMap[card] {
        glog.Infof("not enough energy for %v: %v", card, player.Energy)
        return
    }
    if card == "moveknight" || card == "shoot" {
        if player.Knight.IsDead() {
            glog.Infof("knight dead. skip using card: %v", card)
            return
        }
     } else {
        next := player.Pending[0]

        player.Hand[index] = next
        for i := 1; i < len(player.Pending); i++ {
            player.Pending[i - 1] = player.Pending[i]
        }
        player.Pending[len(player.Pending) - 1] = card

        player.OperateEnergy(-CostMap[card])
        game.Stats[player.Team].EnergyUsed += CostMap[card]
    }

    position := input.Use.Position
    game.AddToWaitingCards(card, position, input.Use.Enable, player)
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
