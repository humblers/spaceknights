package game

import (
	"fmt"

	"github.com/humblers/spaceknights/pkg/data"
)

const maxEnergy = 10000
const startEnergy = 7000
const energyPerFrame = 40
const handSize = 4
const rollingIntervalStep = 30
const knightLeaderIndex = 0

var knightInitialPositionX = []int{500, 200, 800}
var knightInitialPositionY = []int{1450, 1350, 1350}

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
	Score() int
}

type player struct {
	team           Team
	energy         int
	hand           []Card
	pending        []Card
	emptyIdx       []int
	rollingCounter int
	knightIds      []int
	score          int

	statRatios map[string][]int

	game   Game
	client Client
}

func newPlayer(pd PlayerData, g Game) Player {
	p := &player{
		team:       pd.Team,
		energy:     startEnergy,
		score:      leaderScore + wingScore*2,
		statRatios: make(map[string][]int),

		game: g,
	}
	p.hand = append(p.hand, pd.Deck[:handSize]...)
	p.pending = append(p.pending, pd.Deck[handSize:]...)
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

func (p *player) AddKnights(knights []KnightData) {
	for i, k := range knights {
		x := knightInitialPositionX[i]
		y := knightInitialPositionY[i]
		if p.team == Red {
			x = p.game.FlipX(x)
			y = p.game.FlipY(y)
		}
		unit := p.game.AddUnit(k.Name, k.Level, x, y, p)
		if i == knightLeaderIndex {
			unit.SetAsLeader()
		}
		p.knightIds = append(p.knightIds, unit.Id())
	}
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
	p.hand[index] = Card{}
	p.pending = append(p.pending, a.Card)
	p.emptyIdx = append(p.emptyIdx, index)
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

func (p *player) useCard(c Card, tileX, tileY int) error {
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
	isLeader := false
	for i, id := range p.knightIds {
		if id == u.Id() {
			p.knightIds[i] = 0
			if i == 0 {
				isLeader = true
			}
			break
		}
	}
	p.removeCard(u.Name())
	if isLeader {
		p.score -= leaderScore
	} else {
		p.score -= wingScore
	}
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
