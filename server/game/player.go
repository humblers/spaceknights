package main

import (
    "encoding/json"
    "github.com/golang/glog"
)

const MinEnergy = 0
const MaxEnergy = 10000
const EnergyPerFrame = 100
const MovingCost = 50
const HandSize = 3

type Player struct {
    Team Team `json:"-"`
    Hand Cards
    Pending Cards `json:"-"`
    Knight *Unit `json:"-"`
    KnightShotRefuse int
    Energy int
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

func (player *Player) Update() {
    knight := player.Knight
    knight.ClearEvents()
    if knight.IsDead() {
        if knight.RepairFrame == knight.Game.Frame {
            return
        }
        knight.Hp = 1000
        knight.Position = Vector2{MapWidth / 2, MothershipBaseHeight + MothershipMainHeight + TileHeight * 1.5}
        knight.Destination = knight.Position
        knight.HitFrame = 0
        knight.SpawnFrame = 0
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

    if knight.SpawnUntil >= knight.Game.Frame {
        knight.HandleSpawn()
    }

    if player.Energy >= MovingCost && knight.Position != knight.Destination {
        player.OperateEnergy(-MovingCost)
        knight.Game.Stats[player.Team].EnergyUsed += MovingCost
        knight.Velocity = knight.Destination.Minus(knight.Position).Truncate(knight.Speed)
    } else {
        player.OperateEnergy(EnergyPerFrame)
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
	exchange := true
	paycost := true
	needknight := false
	switch card {
	case "moveknight":
		exchange = false; paycost = false; needknight = true
	case "laser":
		needknight = true
	case "shoot":
		exchange = false
		if player.Knight.IsDead() || player.KnightShotRefuse > game.Frame {
			glog.Infof("skip using card: %v", card)
			return
		}
		player.KnightShotRefuse = game.Frame + ActivateAfter + 40
	}
	if needknight && player.Knight.IsDead() {
	    glog.Infof("skip using card: %v. knight dead", card)
		return
	}
    if exchange {
        player.Hand[index] = player.Pending[0]
        for i := 1; i < len(player.Pending); i++ {
            player.Pending[i - 1] = player.Pending[i]
        }
        player.Pending[len(player.Pending) - 1] = card
    }
    if paycost {
        player.OperateEnergy(-CostMap[card])
        game.Stats[player.Team].EnergyUsed += CostMap[card]
    }

    position := input.Use.Position
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
