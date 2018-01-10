package main

import (
    "math/rand"
    "github.com/golang/glog"
)

type Card   string
type Cards  []Card

const ActivateAfter = 10
type WaitingCard struct {
    Name            Card
    Team            Team
    Position        Vector2
    IdStarting      int
    ActivateFrame   int
}

func NewWaitingCard(id int, team Team, card Card, pos Vector2, gameFrame int) *WaitingCard {
    return &WaitingCard{
        Name: card,
        Team: team,
        Position: pos,
        IdStarting: id,
        ActivateFrame: gameFrame + ActivateAfter,
    }
}

func (c *WaitingCard) GetUnitCount() (count int) {
    switch c.Name {
    case "barbarianhut", "bomber", "bombtower", "cannon", "darkprince", "giant", "goblinhut", "megaminion", "minipekka", "musketeer", "pekka", "prince", "tombstone", "valkyrie":
        count = 1
    case "archers":
        count = 2
    case "skeletons", "speargoblins", "minions", "threemusketeers":
        count = 3
    case "barbarians":
        count = 4
	case "minionhorde":
        count = 6
    default:
        glog.Infof("not unit card or invalid card name: %v", c.Name)
    }
    return count
}

var CostMap = map[Card]int{
    "archers": 3000,
    "barbarians": 5000,
    "barbarianhut": 7000,
    "bomber": 3000,
    "bombtower": 5000,
    "cannon": 3000,
    "darkprince": 4000,
    "giant": 5000,
    "goblinhut": 5000,
    "megaminion": 3000,
    "minionhorde": 5000,
    "minions": 3000,
    "minipekka": 4000,
    "musketeer": 4000,
    "pekka": 7000,
    "prince": 5000,
    "skeletons": 1000,
    "speargoblins": 2000,
    "threemusketeers" : 9000,
    "tombstone": 3000,
    "valkyrie": 4000,

    "fireball": 4000,
    "laser": 5000,
    "freeze": 4000,

    "moveknight": 0,
}

// Knuth shuffle
// https://en.wikipedia.org/wiki/Fisher–Yates_shuffle#The_modern_algorithm
func (cards Cards) Shuffle() {
    for i := len(cards) - 1; i > 0; i-- {
        j := rand.Intn(i + 1)
        cards[i], cards[j] = cards[j], cards[i]
    }
}
