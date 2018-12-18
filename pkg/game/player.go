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
const knightTileNumX = 4
const knightTileNumY = 4

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
	KnightDead(side data.KnightSide) bool
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
	if p.game.Step() > data.EnergyBoostAfter {
		p.energy += energyPerFrame * 2
	} else {
		p.energy += energyPerFrame
	}
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

func (p *player) TileValid(tx, ty int, isSpell bool) bool {
	nx := p.game.Map().TileNumX()
	ny := p.game.Map().TileNumY()
	if tx < 0 || tx >= nx {
		return false
	}
	if ty < 0 || ty <= ny {
		return false
	}
	if !isSpell {
		if p.team == Red {
			// flip
			tx = nx - tx
			ty = ny - ty
		}
		if ty < ny/2-5 { // red area
			return false
		}
		if ty <= ny/2 && ty >= ny/2-1 { // obstacle area
			return false
		}
		if ty < ny/2-1 { // conditional area
			opponentSide := data.Left
			if tx < nx/2 {
				opponentSide = data.Right
			}
			if !p.game.FindPlayer(p.opponentTeam()).KnightDead(opponentSide) {
				return false
			}
		}
	}
	return true
}

func (p *player) KnightDead(side data.KnightSide) bool {
	return p.knightIds[side] == 0
}

func (p *player) TileRectValid(tr *tileRect, isSpell bool) bool {
	for i := tr.minX(); i < tr.maxX(); i++ {
		for j := tr.minY(); j < tr.maxY(); j++ {
			if !p.TileValid(i, j, isSpell) {
				return false
			}
		}
	}
	return true
}

func (p *player) opponentTeam() Team {
	if p.team == Blue {
		return Red
	}
	return Blue
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
	index := p.findCard(p.hand, a.Card.Name)
	if index < 0 {
		return fmt.Errorf("card not found: %v, step: %v", a.Card.Name, p.game.Step())
	}
	card := p.hand[index]
	a.Card.Level = card.Level // to protect level cheat

	// energy check
	if p.energy < card.Cost {
		return fmt.Errorf("not enough energy: %v", card.Name)
	}

	// tile check
	nx, ny := card.TileNum()
	tr := &tileRect{a.TileX, a.TileY, nx, ny}
	isSpell := card.IsSpell()
	if !p.TileRectValid(tr, isSpell) {
		return fmt.Errorf("invalid tile: %v", tr)
	}
	if !isSpell {
		tr := p.FindUnoccupiedTileRect(tr, 0)
		if tr == nil {
			return fmt.Errorf("cannot find unoccupied tile")
		} else {
			a.TileX = tr.x
			a.TileY = tr.y
		}
	}

	//  knight check
	if card.Type == data.KnightCard {
		knight := p.findKnight(card.Name)
		if knight == nil {
			// should not be here since we already check card in hand
			return fmt.Errorf("knight not found: %v ", card.Name)
		}
		if !knight.CanCastSkill() {
			return fmt.Errorf("%v cannot cast skill now", knight.Name())
		}
	}

	p.useCard(card, a.TileX, a.TileY)
	p.removeCardFromHand(index)
	p.pending = append(p.pending, card)
	return nil
}

func (p *player) FindUnoccupiedTileRect(tr *tileRect, offset int) *tileRect {
	if offset >= p.game.Map().TileNumY() {
		return nil
	}
	minX := tr.x - offset
	maxX := tr.x + offset
	minY := tr.y - offset
	maxY := tr.y + offset
	for i := minX; i <= maxX; i++ {
		for j := minY; j <= maxY; j++ {
			ox := i - tr.x
			oy := j - tr.y
			if ox < 0 {
				ox = -ox
			}
			if oy < 0 {
				oy = -oy
			}
			if ox+oy != offset {
				continue
			}
			candidate := &tileRect{i, j, tr.numX, tr.numY}
			if !p.TileRectValid(candidate, false) {
				continue
			}
			if p.game.Occupied(candidate) {
				continue
			}
			return candidate
		}
	}
	return p.FindUnoccupiedTileRect(tr, offset+1)
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
