package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type buran struct {
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

func newBuran(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "buran", p.Team(), level, posX, posY, g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, knightTileNumX, knightTileNumY}
	u.Occupy(tr)
	offsetX := g.Map().TileWidth().Mul(fixed.FromInt(HoverKnightTileOffsetX))
	return &buran{
		unit:    u,
		player:  p,
		initPos: u.Position(),
		minPosX: u.Position().X.Sub(offsetX),
		maxPosX: u.Position().X.Add(offsetX),
	}
}

func (b *buran) TakeDamage(amount int, damageType data.DamageType) {
	if damageType == data.Skill || damageType == data.Death {
		amount = amount * data.ReducedDamgeRatioOnKnightBuilding / 100
	}
	b.unit.TakeDamage(amount, damageType)
	if b.IsDead() {
		b.player.OnKnightDead(b)
	}
}

func (b *buran) Destroy() {
	b.unit.Destroy()
	b.Release()
	b.game.Release(b.castTiles, b.id)
}

func (b *buran) attackDamage() int {
	damage := b.unit.attackDamage()
	divider := 1
	for _, ratio := range b.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	damage /= divider
	limits := b.player.StatRatios("amplifycountlimit")
	for i, amplify := range b.player.StatRatios("amplifydamagepersec") {
		cnt := b.attack / data.StepPerSec
		if cnt > limits[i] {
			cnt = limits[i]
		}
		damage += amplify * cnt * b.attackInterval() / data.StepPerSec
	}
	return damage
}

func (b *buran) attackRange() fixed.Scalar {
	atkRange := data.Units[b.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range b.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return b.game.World().FromPixel(atkRange / divider)
}

func (b *buran) Update() {
	if b.freeze > 0 {
		b.attack = 0
		b.targetId = 0
		b.freeze--
		return
	}
	if b.cast > 0 {
		if b.cast == b.preCastDelay()+1 {
			b.spawn()
		}
		if b.cast > b.castDuration() {
			b.cast = 0
			b.setLayer(b.initialLayer())
		} else {
			b.cast++
		}
	} else {
		if b.target() == nil {
			b.setTarget(b.findTarget())
			b.attack = 0
		}
		t := b.target()
		if t != nil && b.canSee(t) {
			posX := t.Position().X
			if posX < b.minPosX {
				posX = b.minPosX
			} else if posX > b.maxPosX {
				posX = b.maxPosX
			}
			b.moveToPos(fixed.Vector{posX, b.Position().Y})
			if b.withinRange(t) {
				if b.attack%b.attackInterval() == 0 {
					t.TakeDamage(b.attackDamage(), b.damageType())
					duration := 0
					for _, d := range b.player.StatRatios("slowduration") {
						duration += d
					}
					t.MakeSlow(duration)
				}
				b.attack++
			} else {
				b.attack = 0
			}
		} else {
			b.moveToPos(b.initPos)
			b.attack = 0
		}
	}
}

func (b *buran) castDuration() int {
	return b.Skill()["castduration"].(int)
}

func (b *buran) preCastDelay() int {
	return b.Skill()["precastdelay"].(int)
}

func (b *buran) SetAsLeader() {
	b.isLeader = true
	b.player.AddStatRatio("amplifydamagepersec", b.Skill()["amplifydamagepersec"].([]int)[b.level])
	b.player.AddStatRatio("amplifycountlimit", b.Skill()["amplifycountlimit"].(int))
}

func (b *buran) Skill() map[string]interface{} {
	skill := data.Units[b.name]["skill"].(map[string]interface{})
	key := "wing"
	if b.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (b *buran) CanCastSkill() bool {
	return b.cast <= 0
}

func (b *buran) CastSkill(posX, posY int) {
	name := b.Skill()["unit"].(string)
	nx := data.Units[name]["tilenumx"].(int)
	ny := data.Units[name]["tilenumy"].(int)
	tx, ty := b.game.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, nx, ny}
	b.game.Occupy(tr, b.id)
	b.castTiles = tr

	b.attack = 0
	b.cast++
	b.castPosX = posX
	b.castPosY = posY
	b.setLayer(data.Casting)
}

func (b *buran) spawn() {
	name := b.Skill()["unit"].(string)
	u := b.game.AddUnit(name, b.level, b.castPosX, b.castPosY, b.player)
	b.game.Release(b.castTiles, b.id)
	u.Occupy(b.castTiles)
	b.castTiles = nil
}

func (b *buran) target() Unit {
	return b.game.FindUnit(b.targetId)
}

func (b *buran) setTarget(u Unit) {
	if u == nil {
		b.targetId = 0
	} else {
		b.targetId = u.Id()
	}
}
