package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type archsapper struct {
	*unit
	player    Player
	isLeader  bool
	targetId  int
	attack    int
	cast      int
	castPosX  int
	castPosY  int
	castTiles *tileRect
}

func newArchsapper(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "archsapper", p.Team(), level, posX, posY, g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, knightTileNumX, knightTileNumY}
	u.Occupy(tr)
	return &archsapper{
		unit:   u,
		player: p,
	}
}

func (a *archsapper) TakeDamage(amount int, damageType data.DamageType) {
	if damageType == data.Skill || damageType == data.Death {
		amount = amount * data.ReducedDamgeRatioOnKnightBuilding / 100
	}
	a.unit.TakeDamage(amount, damageType)
	if a.IsDead() {
		a.player.OnKnightDead(a)
	}
}

func (a *archsapper) Destroy() {
	a.unit.Destroy()
	a.Release()
	a.game.Release(a.castTiles, a.id)
}

func (a *archsapper) attackDamage() int {
	damage := a.unit.attackDamage()
	divider := 1
	for _, ratio := range a.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (a *archsapper) attackRange() fixed.Scalar {
	atkRange := data.Units[a.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range a.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return a.game.World().FromPixel(atkRange / divider)
}

func (a *archsapper) Update() {
	if a.freeze > 0 {
		a.attack = 0
		a.targetId = 0
		a.freeze--
		return
	}
	if a.cast > 0 {
		if a.cast == a.preCastDelay()+1 {
			a.spawn()
		}
		if a.cast > a.castDuration() {
			a.cast = 0
			a.setLayer(a.initialLayer())
		} else {
			a.cast++
		}
	} else {
		if a.attack > 0 {
			a.handleAttack()
		} else {
			t := a.target()
			if t == nil {
				a.findTargetAndAttack()
			} else {
				if a.withinRange(t) {
					a.handleAttack()
				} else {
					a.findTargetAndAttack()
				}
			}
		}
	}
}

func (a *archsapper) castDuration() int {
	return a.Skill()["castduration"].(int)
}

func (a *archsapper) preCastDelay() int {
	return a.Skill()["precastdelay"].(int)
}

func (a *archsapper) findTargetAndAttack() {
	t := a.findTarget()
	a.setTarget(t)
	if t != nil && a.withinRange(t) {
		a.handleAttack()
	}
}

func (a *archsapper) SetAsLeader() {
	a.isLeader = true

	d := a.Skill()
	name := d["unit"].(string)
	count := d["count"].(int)
	xArr := d["posX"].([]int)
	yArr := d["posY"].([]int)

	nx := data.Units[name]["tilenumx"].(int)
	ny := data.Units[name]["tilenumy"].(int)
	for i := 0; i < count; i++ {
		posX, posY := xArr[i], yArr[i]
		if a.player.Team() == Red {
			posX, posY = a.game.FlipX(posX), a.game.FlipY(posY)
		}
		cannon := a.game.AddUnit(name, a.level, posX, posY, a.player)
		tx, ty := a.game.TileFromPos(posX, posY)
		tr := &tileRect{tx, ty, nx, ny}
		cannon.Occupy(tr)
		hp := cannon.InitialHp() * d["hpratio"].([]int)[a.level] / 100
		cannon.SetHp(hp)
		if decayable, ok := cannon.(Decayable); ok {
			decayable.SetDecayOff()
		} else {
			panic("cannot turn off cannon's decay")
		}
	}
}

func (a *archsapper) Skill() map[string]interface{} {
	skill := data.Units[a.name]["skill"].(map[string]interface{})
	key := "wing"
	if a.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (a *archsapper) CanCastSkill() bool {
	return a.cast <= 0
}

func (a *archsapper) CastSkill(posX, posY int) {
	name := a.Skill()["unit"].(string)
	nx := data.Units[name]["tilenumx"].(int)
	ny := data.Units[name]["tilenumy"].(int)
	tx, ty := a.game.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, nx, ny}
	a.game.Occupy(tr, a.id)
	a.castTiles = tr

	a.attack = 0
	a.cast++
	a.castPosX = posX
	a.castPosY = posY
	a.setLayer(data.Casting)
}

func (a *archsapper) spawn() {
	name := a.Skill()["unit"].(string)
	u := a.game.AddUnit(name, a.level, a.castPosX, a.castPosY, a.player)
	a.game.Release(a.castTiles, a.id)
	u.Occupy(a.castTiles)
	a.castTiles = nil
}

func (a *archsapper) target() Unit {
	return a.game.FindUnit(a.targetId)
}

func (a *archsapper) setTarget(u Unit) {
	if u == nil {
		a.targetId = 0
	} else {
		a.targetId = u.Id()
	}
}

func (a *archsapper) handleAttack() {
	if a.attack == a.preAttackDelay() {
		t := a.target()
		if t != nil && a.withinRange(t) {
			a.fire()
		} else {
			a.attack = 0
			return
		}
	}
	a.attack++
	if a.attack > a.attackInterval() {
		a.attack = 0
	}
}

func (a *archsapper) fire() {
	b := newBullet(a.targetId, a.bulletLifeTime(), a.attackDamage(), a.damageType(), a.game)
	duration := 0
	for _, d := range a.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	a.game.AddBullet(b)
}
