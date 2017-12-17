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

func (player *Player) Update() {
    player.RepairKnight()
    player.OperateEnergy(EnergyPerFrame)
}

func (player *Player) RepairKnight() {
    knight := player.Knight
    game := knight.Game
    if knight.IsDead() && knight.RepairFrame == game.Frame {
        knight.Hp = 1000
        knight.Position = Vector2{MapWidth / 2, MothershipBaseHeight + MothershipMainHeight + TileHeight * 1.5}
        game.AddUnit(knight)
        player.SetState(Move, knight.Position, game)
    }
    return
}

func (player *Player) SetState(state State, pos Vector2, game *Game) {
    knight := player.Knight
    knight.State = state
    knight.Position = pos
    switch knight.State {
    case Move, Idle:
        knight.SpawnFrame = 0
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

    if player.Knight.IsDead() {
        glog.Infof("knight dead: card(%v), cur(%v), repair(%v)", card, game.Frame, player.Knight.RepairFrame)
        return
    }

    player.Hand[index] = player.Pending[0]
    for i := 1; i < len(player.Pending); i++ {
        player.Pending[i - 1] = player.Pending[i]
    }
    player.Pending[len(player.Pending) - 1] = card

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
