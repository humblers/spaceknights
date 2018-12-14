package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type pixieking struct {
	*unit
	player    Player
	isLeader  bool
	targetId  int
	attack    int
	cast      int
	initPos   fixed.Vector
	minPosX   fixed.Scalar
	maxPosX   fixed.Scalar
	castPosX  int
	castPosY  int
	castTiles *tileRect
}

func newPixieking(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "pixieking", p.Team(), level, posX, posY, g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, knightTileNumX, knightTileNumY}
	u.Occupy(tr)
	offsetX := g.Map().TileWidth().Mul(fixed.FromInt(HoverKnightTileOffsetX))
	return &pixieking{
		unit:    u,
		player:  p,
		initPos: u.Position(),
		minPosX: u.Position().X.Sub(offsetX),
		maxPosX: u.Position().X.Add(offsetX),
	}
}

func (p *pixieking) TakeDamage(amount int, a Attacker) {
	p.unit.TakeDamage(amount, a)
	if p.IsDead() {
		p.player.OnKnightDead(p)
	}
}

func (p *pixieking) Destroy() {
	p.unit.Destroy()
	p.Release()
	p.game.Release(p.castTiles, p.id)
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
	atkRange := data.Units[p.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range p.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return p.game.World().FromPixel(atkRange / divider)
}

func (p *pixieking) Update() {
	if p.isLeader {
		if p.game.Step()%p.Skill()["perstep"].(int) == 0 {
			p.spawn(p.Skill())
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
			p.spawn(p.Skill())
		}
		if p.cast > p.castDuration() {
			p.cast = 0
			p.setLayer(p.initialLayer())
		} else {
			p.cast++
		}
	} else {
		if p.attack > 0 {
			p.handleAttack()
		} else {
			t := p.target()
			if t == nil {
				p.findTargetAndAttack()
			} else {
				if p.withinRange(t) {
					p.handleAttack()
				} else {
					p.findTargetAndAttack()
				}
			}
		}
	}
}

func (p *pixieking) findTargetAndAttack() {
	t := p.findTarget()
	p.setTarget(t)
	if t != nil && p.withinRange(t) {
		p.handleAttack()
	}
}

func (p *pixieking) castDuration() int {
	return p.Skill()["castduration"].(int)
}

func (p *pixieking) preCastDelay() int {
	return p.Skill()["precastdelay"].(int)
}

func (p *pixieking) SetAsLeader() {
	p.isLeader = true
}

func (p *pixieking) Skill() map[string]interface{} {
	skill := data.Units[p.name]["skill"].(map[string]interface{})
	key := "wing"
	if p.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (p *pixieking) CanCastSkill() bool {
	return p.cast <= 0
}

func (p *pixieking) CastSkill(posX, posY int) {
	name := p.Skill()["unit"].(string)
	nx := data.Units[name]["tilenumx"].(int)
	ny := data.Units[name]["tilenumy"].(int)
	tx, ty := p.game.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, nx, ny}
	p.game.Occupy(tr, p.id)
	p.castTiles = tr

	p.attack = 0
	p.cast++
	p.castPosX = posX
	p.castPosY = posY
	p.setLayer(data.Casting)
}

func (p *pixieking) spawn(data map[string]interface{}) {
	name := data["unit"].(string)
	if name == "pixiegeode" {
		u := p.game.AddUnit(name, p.level, p.castPosX, p.castPosY, p.player)
		p.game.Release(p.castTiles, p.id)
		u.Occupy(p.castTiles)
		p.castTiles = nil
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

func (p *pixieking) handleAttack() {
	if p.attack == p.preAttackDelay() {
		t := p.target()
		if t != nil && p.withinRange(t) {
			p.fire()
		} else {
			p.attack = 0
			return
		}
	}
	p.attack++
	if p.attack > p.attackInterval() {
		p.attack = 0
	}
}

func (p *pixieking) fire() {
	b := newBullet(p.targetId, p.bulletLifeTime(), p.attackDamage(), p.DamageType(), p.game)
	duration := 0
	for _, d := range p.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	p.game.AddBullet(b)
}
