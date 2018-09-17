package game

import (
	"fmt"
)

const maxEnergy = 10000
const startEnergy = 7000
const energyPerFrame = 40
const handSize = 4
const rollingIntervalStep = 30
const knightLeaderIndex = 0

var knightInitialPositionX = []int{500, 200, 800}
var knightInitialPositionY = []int{1600, 1600, 1600}

type Player interface {
	Client() Client
	SetClient(c Client)

	Team() Team

	StatRatios(name string) []int
	AddStatRatio(name string, ratio int)

	AddKnights(knights []KnightData)
	Do(a *Action) error
	OnKnightDead(u Unit)
	Update()
}

type player struct {
	team           Team
	energy         int
	hand           []Card
	pending        []Card
	emptyIdx       []int
	rollingCounter int
	knightIds      []int

	statRatios map[string][]int

	game   Game
	client Client
}

func newPlayer(pd PlayerData, g Game) Player {
	p := &player{
		team:       pd.Team,
		energy:     startEnergy,
		hand:       pd.Deck[:handSize],
		pending:    pd.Deck[handSize:],
		statRatios: make(map[string][]int),

		game: g,
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

func (p *player) AddKnights(knights []KnightData) {
	for i, k := range knights {
		x := knightInitialPositionX[i]
		y := knightInitialPositionY[i]
		if p.team == Red {
			x = p.game.FlipX(x)
			y = p.game.FlipY(y)
		}
		id := p.game.AddUnit(k.Name, k.Level, x, y, p)
		if i == knightLeaderIndex {
			p.game.FindUnit(id).SetAsLeader()
		}
		p.knightIds = append(p.knightIds, id)
	}
}

func (p *player) StatRatios(name string) []int {
	return p.statRatios[name]
}

func (p *player) AddStatRatio(name string, ratio int) {
	p.statRatios[name] = append(p.statRatios[name], ratio)
}

func (p *player) Update() {
	p.energy += energyPerFrame
	if p.energy > maxEnergy {
		p.energy = maxEnergy
	}
	p.rollingCard()
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

	posX, posY, err := p.game.PosFromTile(a.TileX, a.TileY)
	if err != nil {
		return err
	}
	if cards[a.Card.Name]["unit"] != nil {
		if p.team == Red && a.TileY > p.game.Map().MaxTileYOnTop() {
			return fmt.Errorf("can't place card on tileY: %v", a.TileY)
		}
		if p.team == Blue && a.TileY < p.game.Map().MinTileYOnBot() {
			return fmt.Errorf("can't place card on tileY: %v", a.TileY)
		}
	}

	if err := p.useCard(a.Card, posX, posY); err != nil {
		return err
	}

	// decrement energy
	p.energy -= cost
	// put empty card
	p.hand[index] = Card{}
	p.emptyIdx = append(p.emptyIdx, index)
	p.pending = append(p.pending, a.Card)
	return nil
}

func (p *player) findKnight(name string) Unit {
	for _, id := range p.knightIds {
		u := p.game.FindUnit(id)
		if u != nil && u.Name() == name {
			return u
		}
	}
	return nil
}

func (p *player) useCard(c Card, posX, posY int) error {
	card := cards[c.Name]
	if card["caster"] != nil {
		k := p.findKnight(card["caster"].(string))
		if k == nil {
			panic("should not be here")
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

func (p *player) rollingCard() {
	if p.rollingCounter > 0 {
		p.rollingCounter--
		return
	}
	if len(p.emptyIdx) == 0 {
		return
	}
	var next Card
	var idx int
	next, p.pending = p.pending[0], p.pending[1:]
	idx, p.emptyIdx = p.emptyIdx[0], p.emptyIdx[1:]
	p.hand[idx] = next
	p.rollingCounter = rollingIntervalStep
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
