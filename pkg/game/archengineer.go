package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type archengineer struct {
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

func newArchengineer(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "archengineer", p.Team(), level, posX, posY, g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, knightTileNumX, knightTileNumY}
	u.Occupy(tr)
	return &archengineer{
		unit:   u,
		player: p,
	}
}

func (a *archengineer) TakeDamage(amount int, damageType data.DamageType) {
	if damageType == data.Skill || damageType == data.Death {
		amount = amount * data.ReducedDamgeRatioOnKnightBuilding / 100
	}
	a.unit.TakeDamage(amount, damageType)
	if a.IsDead() {
		a.player.OnKnightDead(a)
	}
}

func (a *archengineer) Destroy() {
	a.unit.Destroy()
	a.Release()
	a.game.Release(a.castTiles, a.id)
}

func (a *archengineer) attackDamage() int {
	damage := a.unit.attackDamage()
	divider := 1
	for _, ratio := range a.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (a *archengineer) attackRange() fixed.Scalar {
	atkRange := data.Units[a.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range a.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return a.game.World().FromPixel(atkRange / divider)
}

func (a *archengineer) Update() {
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

func (a *archengineer) castDuration() int {
	return a.Skill()["castduration"].(int)
}

func (a *archengineer) preCastDelay() int {
	return a.Skill()["precastdelay"].(int)
}

func (a *archengineer) findTargetAndAttack() {
	t := a.findTarget()
	a.setTarget(t)
	if t != nil && a.withinRange(t) {
		a.handleAttack()
	}
}

func (a *archengineer) SetAsLeader() {
	a.isLeader = true
	//a.player.AddStatRatio("arearatio", a.Skill()["arearatio"].(int))
}

func (a *archengineer) Skill() map[string]interface{} {
	skill := data.Units[a.name]["skill"].(map[string]interface{})
	key := "wing"
	if a.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (a *archengineer) CanCastSkill() bool {
	return a.cast <= 0
}

func (a *archengineer) CastSkill(posX, posY int) {
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

func (a *archengineer) spawn() {
	name := a.Skill()["unit"].(string)
	u := a.game.AddUnit(name, a.level, a.castPosX, a.castPosY, a.player)
	a.game.Release(a.castTiles, a.id)
	u.Occupy(a.castTiles)
	a.castTiles = nil
}

func (a *archengineer) target() Unit {
	return a.game.FindUnit(a.targetId)
}

func (a *archengineer) setTarget(u Unit) {
	if u == nil {
		a.targetId = 0
	} else {
		a.targetId = u.Id()
	}
}

func (a *archengineer) handleAttack() {
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

func (a *archengineer) fire() {
	b := newBullet(a.targetId, a.bulletLifeTime(), a.attackDamage(), a.damageType(), a.game)
	duration := 0
	for _, d := range a.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	a.game.AddBullet(b)
}
