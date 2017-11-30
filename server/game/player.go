package main

import (
    "encoding/json"
    "github.com/golang/glog"
)

const MaxEnergy = 10000
const EnergyPerFrame = 70
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

func (player *Player) RepairKnight(game *Game) {
    if player.Knight.Hp <= 0 && player.Knight.RepairFrame == game.Frame {
        knight := player.Knight
        knight.Hp = 100
        knight.Position = Vector2{MapWidth / 2, MothershipBaseHeight + MothershipMainHeight + TileHeight * 1.5}
        knight.SpawnFrame = game.Frame + knight.SpawnSpeed
        knight.SpawnStack = 0
        knight.HitFrame = 0
        game.AddUnit(knight)
    }
    return
}

const MovementDelay = 1
func (player *Player) AddMovement(x float64, frame int) {
    posX := x
    if player.Team == Visitor {
        posX = MapWidth - x
    }
    player.Movements = append(player.Movements, &Movement{posX, frame + MovementDelay})
}

func (player *Player) Move(frame int) {
    var unhandled []*Movement
    for _, m := range player.Movements {
        if frame > m.Frame {
            player.Knight.InputPositionX = m.PositionX
        } else {
            unhandled = append(unhandled, m)
        }
    }
    player.Movements = unhandled
}

func (player *Player) UseCard(index int, position Vector2, game *Game) {
    if player.Knight.Hp <= 0 {
        return
    }

    var card Card = "moveknight"
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
    game.Stats[player.Team].EnergyUsed += CostMap[card] / 1000

    game.AddToWaitingCards(card, position, player)
}

func (player *Player) IncreaseEnergy(amount int) {
    if player.Energy += amount; player.Energy > MaxEnergy {
        player.Energy = MaxEnergy
    }
}
