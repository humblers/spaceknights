package main

import "math/rand"

type Card string
type Cards []Card

var CostMap = map[Card]int{
    "archer": 30,
    "babydragon": 40,
    "barbarian": 50,
    "bomber": 30,
    "cannon": 40,
    "giant": 50,
}

// Knuth shuffle
// https://en.wikipedia.org/wiki/Fisher–Yates_shuffle#The_modern_algorithm
func (cards Cards) Shuffle() {
    for i := len(cards) - 1; i > 0; i-- {
        j := rand.Intn(i + 1)
        cards[i], cards[j] = cards[j], cards[i]
    }
}
