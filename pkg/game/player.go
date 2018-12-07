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
	team      Team
	energy    int
	hand      []*data.Card
	pending   []*data.Card
	emptyIdx  []int
	drawTimer int
	knightIds map[data.KnightSide]int
	score     int

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
	for _, c := range pd.Deck {
		card := data.NewCard(c)
		if card.Side != data.Center {
			if len(p.hand) < handSize {
				p.hand = append(p.hand, card)
			} else {
				p.pending = append(p.pending, card)
			}
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
	if p.canDrawCard() {
		index := p.emptyIdx[0]
		p.emptyIdx = p.emptyIdx[1:]
		p.drawCard(index)
	} else {
		p.drawTimer--
	}
}

func (p *player) canDrawCard() bool {
	if p.drawTimer > 0 {
		return false
	}
	if len(p.emptyIdx) == 0 {
		return false
	}
	return true
}

func (p *player) drawCard(index int) {
	var next *data.Card
	next, p.pending = p.pending[0], p.pending[1:]
	p.hand[index] = next
	p.drawTimer = drawInterval
}

func (p *player) Do(a *Action) error {
	if a.Card.Name == "" {
		if a.Message == "" {
			return fmt.Errorf("invalid action: %v", *a)
		} else {
			return nil // no op
		}
	}

	index := p.findCard(p.hand, a.Card.Name)
	if index < 0 {
		return fmt.Errorf("card not found: %v, step: %v", a.Card.Name, p.game.Step())
	}
	card := p.hand[index]
	a.Card.Level = card.Level // to protect level cheat

	if err := p.canUseCard(card, a.TileX, a.TileY); err != nil {
		return err
	}
	p.useCard(card, a.TileX, a.TileY)

	p.removeCardFromHand(index)
	p.pending = append(p.pending, card)
	return nil
}

func (p *player) canUseCard(card *data.Card, tileX, tileY int) error {
	if p.energy < card.Cost {
		return fmt.Errorf("not enough energy: %v", card.Name)
	}
	if !p.game.IsValidTile(tileX, tileY) {
		return fmt.Errorf("invalid tile index: (%v, %v)", tileX, tileY)
	}
	if !p.CanUseAnywhere(card) {
		if p.team == Red && tileY > p.game.Map().MaxTileYOnTop() {
			return fmt.Errorf("can't place card on tileY: %v", tileY)
		}
		if p.team == Blue && tileY < p.game.Map().MinTileYOnBot() {
			return fmt.Errorf("can't place card on tileY: %v", tileY)
		}
	}
	if card.Type == data.KnightCard {
		knight := p.findKnight(card.Name)
		if knight == nil {
			return fmt.Errorf("%v already dead", card.Name)
		}
		if !knight.CanCastSkill() {
			return fmt.Errorf("%v cannot cast skill now", knight.Name())
		}
	}
	return nil
}

func (p *player) CanUseAnywhere(card *data.Card) bool {
	if card.Type == data.KnightCard {
		skill := data.Units[card.Name]["skill"].(map[string]interface{})["wing"].(map[string]interface{})
		if _, ok := skill["unit"]; !ok {
			return true
		} else {
			if data.Units[skill["unit"].(string)]["type"] != data.Building {
				return true
			}
		}
	}
	return false
}

func (p *player) findCard(from []*data.Card, name string) int {
	for i, c := range from {
		if c != nil && c.Name == name {
			return i
		}
	}
	return -1
}

func (p *player) removeCardFromHand(index int) {
	p.hand[index] = nil
	p.emptyIdx = append(p.emptyIdx, index)
}

func (p *player) removeCardFromPending(index int) {
	p.pending = append(p.pending[:index], p.pending[index+1:]...)
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

func (p *player) useCard(card *data.Card, tileX, tileY int) {
	posX, posY := p.game.PosFromTile(tileX, tileY)
	if card.Type == data.KnightCard {
		p.findKnight(card.Name).CastSkill(posX, posY)
	} else {
		for i := 0; i < card.Count; i++ {
			p.game.AddUnit(card.Unit, card.Level, posX+card.OffsetX[i], posY+card.OffsetY[i], p)
		}
	}
	p.energy -= card.Cost
}

func (p *player) OnKnightDead(knight Unit) {
	for side, id := range p.knightIds {
		if id == knight.Id() {
			p.knightIds[side] = 0
			if side == data.Center {
				p.score -= leaderScore
			} else {
				p.score -= wingScore
			}
			break
		}
	}
	index := p.findCard(p.hand, knight.Name())
	if index >= 0 {
		p.removeCardFromHand(index)
	}
	index = p.findCard(p.pending, knight.Name())
	if index >= 0 {
		p.removeCardFromPending(index)
	}
}
