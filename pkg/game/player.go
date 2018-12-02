package game

import (
	"fmt"

	"github.com/humblers/spaceknights/pkg/data"
)

const maxEnergy = 10000
const startEnergy = 7000
const energyPerFrame = 40
const handSize = 4
const drawInterval = 30

var initialKnightPositionX = map[data.KnightSide]int{
	"Left":   200,
	"Center": 500,
	"Right":  800,
}
var initialKnightPositionY = map[data.KnightSide]int{
	"Left":   1350,
	"Center": 1450,
	"Right":  1350,
}

type Player interface {
	Client() Client
	SetClient(c Client)

	Team() Team

	StatRatios(name string) []int
	AddStatRatio(name string, ratio int)

	Do(a *Action) error
	OnKnightDead(u Unit)
	Update()
	Score() int
}

type player struct {
	team        Team
	energy      int
	hand        []data.Card
	pending     []data.Card
	emptyIdx    []int
	drawCounter int
	knightIds   map[data.KnightSide]int
	score       int

	statRatios map[string][]int

	game   Game
	client Client
}

func newPlayer(pd PlayerData, g Game) Player {
	p := &player{
		team:       pd.Team,
		energy:     startEnergy,
		knightIds:  make(map[data.KnightSide]int),
		score:      leaderScore + wingScore*2,
		statRatios: make(map[string][]int),

		game: g,
	}
	for i, card := range pd.Deck {
		card = data.NewCard(card)
		if i < handSize {
			p.hand = append(p.hand, card)
		} else {
			p.pending = append(p.pending, card)
		}
		if card.Type == data.KnightCard {
			p.addKnight(card.Name, card.Level, card.Side)
		}
	}
	p.applyLeaderSkill()
	return p
}

func (p *player) Client() Client {
	return p.client
}
func (p *player) SetClient(c Client) {
	p.client = c
}

func (p *player) Score() int {
	return p.score
}

func (p *player) Team() Team {
	return p.team
}

func (p *player) StatRatios(name string) []int {
	return p.statRatios[name]
}

func (p *player) AddStatRatio(name string, ratio int) {
	p.statRatios[name] = append(p.statRatios[name], ratio)
}

func (p *player) addKnight(name string, level int, side data.KnightSide) {
	x := initialKnightPositionX[side]
	y := initialKnightPositionY[side]
	if p.team == Red {
		x = p.game.FlipX(x)
		y = p.game.FlipY(y)
	}
	knight := p.game.AddUnit(name, level, x, y, p)
	p.knightIds[side] = knight.Id()
}

func (p *player) applyLeaderSkill() {
	p.game.FindUnit(p.knightIds[data.Center]).SetAsLeader()

	// apply hp buff
	for _, id := range p.knightIds {
		knight := p.game.FindUnit(id)
		hp := knight.Hp()
		divider := 1
		for _, ratio := range p.StatRatios("hpratio") {
			hp *= ratio
			divider *= 100
		}
		knight.SetHp(hp / divider)
	}
}

func (p *player) Update() {
	p.energy += energyPerFrame
	if p.energy > maxEnergy {
		p.energy = maxEnergy
	}
	p.drawCard()
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
		return fmt.Errorf("card not found: %v, step: %v", a.Card.Name, p.game.Step())
	}

	// check energy
	cost := data.Cards[a.Card.Name].Cost
	if p.energy < cost {
		return fmt.Errorf("not enough energy: %v", a.Card.Name)
	}

	if err := p.useCard(a.Card, a.TileX, a.TileY); err != nil {
		return err
	}

	// decrement energy
	p.energy -= cost

	// put empty card
	if index >= 0 {
		p.hand[index] = data.Card{}
		p.pending = append(p.pending, a.Card)
		p.emptyIdx = append(p.emptyIdx, index)
	}
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

func (p *player) useCard(c data.Card, tileX, tileY int) error {
	posX, posY, err := p.game.PosFromTile(tileX, tileY)
	if err != nil {
		return err
	}

	d := data.Cards[c.Name]
	name := d.Unit
	u := data.Units[name]
	k := p.findKnight(name)
	isKnight := u["type"].(data.UnitType) == data.Knight
	if !isKnight || k.Skill()["unit"] != nil {
		if p.team == Red && tileY > p.game.Map().MaxTileYOnTop() {
			return fmt.Errorf("can't place card on tileY: %v", tileY)
		}
		if p.team == Blue && tileY < p.game.Map().MinTileYOnBot() {
			return fmt.Errorf("can't place card on tileY: %v", tileY)
		}
	}

	if isKnight {
		if k == nil {
			panic("should not be here")
		}
		if !k.CastSkill(posX, posY) {
			return fmt.Errorf("%v cannot cast skill now", k.Name())
		}
	} else {
		for i := 0; i < d.Count; i++ {
			p.game.AddUnit(name, c.Level, posX+d.OffsetX[i], posY+d.OffsetY[i], p)
		}
	}
	return nil
}

func (p *player) drawCard() {
	if p.drawCounter > 0 {
		p.drawCounter--
		return
	}
	if len(p.emptyIdx) == 0 {
		return
	}
	var next data.Card
	var idx int
	next, p.pending = p.pending[0], p.pending[1:]
	idx, p.emptyIdx = p.emptyIdx[0], p.emptyIdx[1:]
	p.hand[idx] = next
	p.drawCounter = drawInterval
}

func (p *player) OnKnightDead(u Unit) {
	for side, id := range p.knightIds {
		if id == u.Id() {
			p.knightIds[side] = 0
			if side == data.Center {
				p.score -= leaderScore
			} else {
				p.score -= wingScore
			}
			break
		}
	}
	p.removeCard(u.Name())
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
			return
		}
	}
}
