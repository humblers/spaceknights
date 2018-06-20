package main

import (
	"math/rand"

	"github.com/golang/glog"
)

type Card string
type Cards []Card

const ActivateAfter = 10

type WaitingCard struct {
	Name          Card
	Team          Team
	Position      Vector2
	IdStarting    int
	ActivateFrame int
	Knight        *Unit
}

func NewWaitingCard(id int, team Team, card Card, pos Vector2, gameFrame int, knight *Unit) *WaitingCard {
	return &WaitingCard{
		Name:          card,
		Team:          team,
		Position:      pos,
		IdStarting:    id,
		ActivateFrame: gameFrame + ActivateAfter,
		Knight:        knight,
	}
}

func (c *WaitingCard) GetUnitCount() (count int) {
	switch c.Name {
	case "barrack", "blaster", "blastturret", "cannon", "jouster", "giant", "sentryshelter", "drillram", "gargoyleking", "berserker", "starfire", "ogre", "champion", "pixiegeode", "enforcer", "panzerkunstler", "psabu", "shadowvision", "wasp" :
		count = 1
	case "archers":
		count = 2
	case "pixie", "sentry", "gargoyles", "threestarfire", "trainee":
		count = 3
	case "footman":
		count = 4
	case "felhound":
		count = 5
	case "gargoylehorde":
		count = 6
	default:
		glog.Infof("not unit card or invalid card name: %v", c.Name)
	}
	return count
}

var CostMap = map[Card]int{
	"archers":         3000,
	"footman":      5000,
	"barrack":    7000,
	"blaster":          3000,
	"blastturret":       5000,
	"cannon":          3000,
	"jouster":      4000,
	"giant":           5000,
	"sentryshelter":       5000,
	"drillram":        4000,
	"gargoyleking":      3000,
	"gargoylehorde":     5000,
	"gargoyles":         3000,
	"berserker":       4000,
	"starfire":       4000,
	"ogre":           7000,
	"champion":          5000,
	"pixie":       1000,
	"sentry":    2000,
	"threestarfire": 9000,
	"pixiegeode":       3000,
	"felhound":        2000,
	"panzerkunstler":        5000,
	"psabu":        7000,
	"shadowvision":        4000,
	"trainee":        2000,
	"wasp":        5000,

	"fireball": 11000,
	"laser":    11000,
	"freeze":   11000,
}

func CreateRandomDeck() Cards {
	unitCards := make(Cards, 0, len(CostMap))
	for name, _ := range CostMap {
		if name == "fireball" || name == "laser" || name == "freeze" {
			continue
		}
		unitCards = append(unitCards, name)
	}

	unitCards.Shuffle()
	return unitCards[:HandSize]
}

// Knuth shuffle
// https://en.wikipedia.org/wiki/Fisher–Yates_shuffle#The_modern_algorithm
func (cards Cards) Shuffle() {
	for i := len(cards) - 1; i > 0; i-- {
		j := rand.Intn(i + 1)
		cards[i], cards[j] = cards[j], cards[i]
	}
}
