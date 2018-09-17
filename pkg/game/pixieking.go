package game

import "github.com/humblers/spaceknights/pkg/fixed"

type pixieking struct {
	*unit
	TileOccupier
	player   Player
	isLeader bool
	targetId int
	attack   int
	cast     int
	initPos  fixed.Vector
	minPosX  fixed.Scalar
	maxPosX  fixed.Scalar
	castPosX int
	castPosY int
	castTile TileOccupier
}

func newPixieking(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "pixieking", p.Team(), level, posX, posY, g)
	hp := u.hp
	divider := 1
	for _, ratio := range p.StatRatios("hpratio") {
		hp *= ratio
		divider *= 100
	}
	u.hp = hp / divider
	to := newTileOccupier(g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{t: ty - 2, b: ty + 1, l: tx - 2, r: tx + 1}
	if err := to.Occupy(tr); err != nil {
		panic(err)
	}
	offsetX := g.Map().TileWidth().Mul(fixed.FromInt(HoverKnightTileOffsetX))
	return &pixieking{
		unit:         u,
		TileOccupier: to,
		player:       p,
		initPos:      u.Position(),
		minPosX:      u.Position().X.Sub(offsetX),
		maxPosX:      u.Position().X.Add(offsetX),
		castTile:     newTileOccupier(g),
	}
}

func (p *pixieking) TakeDamage(amount int, t AttackType) {
	p.unit.TakeDamage(amount, t)
	if p.IsDead() {
		p.player.OnKnightDead(p)
	}
}

func (p *pixieking) Destroy() {
	p.unit.Destroy()
	p.TileOccupier.Release()
	p.castTile.Release()
}

func (p *pixieking) attackDamage() int {
	damage := p.unit.attackDamage()
	divider := 1
	for _, ratio := range p.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (p *pixieking) attackRange() fixed.Scalar {
	atkRange := units[p.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range p.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return p.game.World().FromPixel(atkRange / divider)
}

func (p *pixieking) Update() {
	if p.isLeader {
		data := passives[p.Skill()]
		if p.game.Step()%data["perstep"].(int) == 0 {
			p.spawn(data)
		}
	}
	if p.freeze > 0 {
		p.attack = 0
		p.targetId = 0
		p.freeze--
		return
	}
	if p.cast > 0 {
		if p.cast == p.preCastDelay()+1 {
			p.spawn(cards[p.Skill()])
		}
		if p.cast > p.castDuration() {
			p.cast = 0
			p.setLayer(p.initialLayer())
		} else {
			p.cast++
		}
	} else {
		if p.target() == nil {
			p.setTarget(p.findTarget())
			p.attack = 0
		}
		t := p.target()
		if t != nil && p.canSee(t) {
			posX := t.Position().X
			if posX < p.minPosX {
				posX = p.minPosX
			} else if posX > p.maxPosX {
				posX = p.maxPosX
			}
			p.moveTo(fixed.Vector{posX, p.Position().Y})
			if p.withinRange(t) {
				if p.attack%p.attackInterval() == 0 {
					t.TakeDamage(p.attackDamage(), Range)
					duration := 0
					for _, d := range p.player.StatRatios("slowduration") {
						duration += d
					}
					t.MakeSlow(duration)
				}
				p.attack++
			} else {
				p.attack = 0
			}
		} else {
			p.moveTo(p.initPos)
			p.attack = 0
		}
	}
}

func (p *pixieking) castDuration() int {
	return cards[p.Skill()]["castduration"].(int)
}

func (p *pixieking) preCastDelay() int {
	return cards[p.Skill()]["precastdelay"].(int)
}

func (p *pixieking) SetAsLeader() {
	p.isLeader = true
}

func (p *pixieking) Skill() string {
	key := "active"
	if p.isLeader {
		key = "passive"
	}
	return units[p.name][key].(string)
}

func (p *pixieking) CastSkill(posX, posY int) bool {
	if p.cast > 0 {
		return false
	}

	name := cards[p.Skill()]["unit"].(string)
	nx := units[name]["tilenumx"].(int)
	ny := units[name]["tilenumy"].(int)
	tx, ty := p.game.TileFromPos(posX, posY)
	tr := p.castTile.GetRect(tx, ty, nx, ny)
	if err := p.castTile.Occupy(tr); err != nil {
		p.game.Logger().Print(err)
		return false
	}

	p.attack = 0
	p.cast++
	p.castPosX = posX
	p.castPosY = posY
	p.setLayer(Casting)
	return true
}

func (p *pixieking) spawn(data map[string]interface{}) {
	name := data["unit"].(string)
	if name == "pixiegeode" {
		id := p.game.AddUnit(name, p.level, p.castPosX, p.castPosY, p.player)
		tr := p.castTile.Occupied()
		p.castTile.Release()
		if occupier, ok := p.game.FindUnit(id).(TileOccupier); ok {
			if err := occupier.Occupy(tr); err != nil {
				panic(err)
			}
		}
	}
	if name == "pixie" {
		count := data["count"].(int)
		offsetX := data["offsetX"].([]int)
		offsetY := data["offsetY"].([]int)
		posX := p.game.World().ToPixel(p.initPos.X)
		posY := p.game.World().ToPixel(p.initPos.Y)
		for i := 0; i < count; i++ {
			p.game.AddUnit(name, p.level, posX+offsetX[i], posY+offsetY[i], p.player)
		}
	}
}

func (p *pixieking) target() Unit {
	return p.game.FindUnit(p.targetId)
}

func (p *pixieking) setTarget(u Unit) {
	if u == nil {
		p.targetId = 0
	} else {
		p.targetId = u.Id()
	}
}
