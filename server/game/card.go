package main

import (
    "math/rand"
    "github.com/golang/glog"
)

type Card   string
type Cards  []Card

const ActivateAfter = 5
type WaitingCard struct {
    Name            Card
    Team            Team
    Position        Vector2
    IdStarting      int
    ActivateFrame   int
}

func (c *WaitingCard) GetUnitCount() (count int) {
    switch c.Name {
    case "bomber", "cannon", "giant", "megaminion", "minipekka", "musketeer", "pekka", "valkyrie":
        count = 1
    case "archers":
        count = 2
    case "skeletons", "speargoblins":
        count = 3
    case "barbarians":
        count = 4
    default:
        glog.Infof("not unit card or invalid card name: %v", c.Name)
    }
    return count
}

var CostMap = map[Card]int{
    "archers": 0,
    "barbarians": 0,
    "bomber": 0,
    "cannon": 0,
    "giant": 0,
    "megaminion": 0,
    "minipekka": 0,
    "musketeer": 0,
    "pekka": 0,
    "skeletons": 0,
    "speargoblins": 0,
    "valkyrie": 0,
}

// Knuth shuffle
// https://en.wikipedia.org/wiki/Fisher–Yates_shuffle#The_modern_algorithm
func (cards Cards) Shuffle() {
    for i := len(cards) - 1; i > 0; i-- {
        j := rand.Intn(i + 1)
        cards[i], cards[j] = cards[j], cards[i]
    }
}
