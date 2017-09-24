package main

import "math/rand"

type Card string
type Cards []Card

var CostMap = map[Card]int{
    "archer": 0,
    "barbarian": 0,
    "bomber": 0,
    "cannon": 0,
    "giant": 0,
    "megaminion": 0,
    "minipekka": 0,
    "musketeer": 0,
    "pekka": 0,
    "skeleton": 0,
    "speargoblin": 0,
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
