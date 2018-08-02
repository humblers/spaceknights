package game

import "fmt"

const maxEnergy = 10000
const startEnergy = 7000
const energyPerFrame = 40
const handSize = 4

var knightInitialPositionX = []int{200, 500, 800}
var knightInitialPositionY = []int{1600, 1600, 1600}

type Player interface {
	Client() Client
	SetClient(c Client)

	Team() Team
	Do(a *Action) error
	Update()
	OnKnightDead(u Unit)
}

type player struct {
	team      Team
	energy    int
	hand      []Card
	pending   []Card
	knightIds []int

	game   Game
	client Client
}

func newPlayer(pd PlayerData, g Game) Player {
	p := &player{
		team:    pd.Team,
		energy:  startEnergy,
		hand:    pd.Deck[:handSize],
		pending: pd.Deck[handSize:],

		game: g,
	}
	for i, k := range pd.Knights {
		id := g.AddUnit(k.Name, k.Level, knightInitialPositionX[i], knightInitialPositionY[i], p)
		p.knightIds = append(p.knightIds, id)
	}
	return p
}

func (p *player) Client() Client {
	return p.client
}
func (p *player) SetClient(c Client) {
	p.client = c
}
func (p *player) Team() Team {
	return p.team
}

func (p *player) Update() {
	p.energy += energyPerFrame
	if p.energy > maxEnergy {
		p.energy = maxEnergy
	}
}

func (p *player) Do(a *Action) error {
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

	// check energy
	cost := cards[a.Card.Name]["cost"].(int)
	if p.energy < cost {
		return fmt.Errorf("not enough energy: %v", a.Card.Name)
	}

	if err := p.useCard(a.Card, a.PosX, a.PosY); err != nil {
		return err
	}

	// decrement energy
	p.energy -= cost
	// deck rolling
	p.hand[index] = p.pending[0]
	for i := 1; i < len(p.pending); i++ {
		p.pending[i-1] = p.pending[i]
	}
	p.pending[len(p.pending)-1] = a.Card
	return nil
}

func (p *player) findKnight(name string) Unit {
	for _, id := range p.knightIds {
		u := p.game.FindUnit(id)
		if u.Name() == name {
			return u
		}
	}
	return nil
}

func (p *player) useCard(c Card, posX, posY int) error {
	card := cards[c.Name]
	if card["unit"] == nil {
		k := p.findKnight(card["caster"].(string))
		if k == nil {
			panic("should not be here")
		}
		if p.team == Red {
			posX = p.game.World().ToPixel(p.game.Map().Width()) - posX
			posY = p.game.World().ToPixel(p.game.Map().Height()) - posY
		}
		if !k.CastSkill(posX, posY) {
			return fmt.Errorf("%v cannot cast skill now", k.Name())
		}
	} else {
		name := card["unit"].(string)
		count := card["count"].(int)
		offsetX := card["offsetX"].([]int)
		offsetY := card["offsetY"].([]int)
		for i := 0; i < count; i++ {
			p.game.AddUnit(name, c.Level, posX+offsetX[i], posY+offsetY[i], p)
		}
	}
	return nil
}

func (p *player) OnKnightDead(u Unit) {
	for i, id := range p.knightIds {
		if id == u.Id() {
			p.knightIds[i] = 0
			break
		}
	}
	p.removeCard(u.Skill())
}

func (p *player) removeCard(name string) {
	for i, c := range p.hand {
		if c.Name == name {
			p.hand[i] = p.pending[0]
			p.pending = p.pending[1:]
			return
		}
	}
	for i, c := range p.pending {
		if c.Name == name {
			p.pending = append(p.pending[:i], p.pending[i+1:]...)
			break
		}
	}
}
