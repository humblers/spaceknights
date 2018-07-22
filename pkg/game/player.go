package game

import "fmt"

const maxEnergy = 10000
const startEnergy = 7000
const energyPerFrame = 40
const handSize = 4

type player struct {
	id      string
	team    Team
	energy  int
	hand    []Card
	pending []Card
	knights []Unit

	game   *game
	client *client
}

func newPlayer(p Player, g *game) *player {
	return &player{
		id:      p.Id,
		team:    p.Team,
		energy:  startEnergy,
		hand:    p.Deck[:handSize],
		pending: p.Deck[handSize:],

		game: g,
	}
}

func (p *player) update() {
	p.energy += energyPerFrame
	if p.energy > maxEnergy {
		p.energy = maxEnergy
	}
}

func (p *player) do(a *Action) error {
	if a.Card.Name == "" {
		if a.Message == "" {
			return fmt.Errorf("invalid action: %v", *a)
		} else {
			return nil // no op
		}
	}

	// find card in hand
	index := -1
	for i, c := range p.hand {
		if c.Name == a.Card.Name {
			index = i
			a.Card.Level = c.Level // to protect level cheat
			break
		}
	}
	if index < 0 {
		return fmt.Errorf("card not found: %v", a.Card.Name)
	}

	// decrement energy
	cost := cost[a.Card.Name]
	if p.energy < cost {
		return fmt.Errorf("not enough energy: %v", a.Card.Name)
	}
	p.energy -= cost

	// deck rolling
	p.hand[index] = p.pending[0]
	for i := 1; i < len(p.pending); i++ {
		p.pending[i-1] = p.pending[i]
	}
	p.pending[len(p.pending)-1] = a.Card

	p.useCard(a.Card, a.PosX, a.PosY)
	return nil
}

func (p *player) useCard(c Card, posX, posY int) {
	switch c.Name {
	case "archers":
		p.game.AddUnit("archer", p.team, c.Level, posX-5, posY)
		p.game.AddUnit("archer", p.team, c.Level, posX+5, posY)
	}
}
