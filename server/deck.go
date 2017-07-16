package main

import "math/rand"

type Card string
type Deck [DeckSize]Card

// Knuth shuffle
// https://en.wikipedia.org/wiki/Fisher–Yates_shuffle#The_modern_algorithm
func (deck *Deck) Shuffle() {
    for i := len(deck) - 1; i > 0; i-- {
        j := rand.Intn(i + 1)
        deck[i], deck[j] = deck[j], deck[i]
    }
}
