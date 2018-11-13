package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type frost struct {
	*unit
	TileOccupier
	player   Player
	isLeader bool
	targetId int
	attack   int
	cast     int
	castPosX int
	castPosY int
}

func newFrost(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "frost", p.Team(), level, posX, posY, g)
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
	return &frost{
		unit:         u,
		TileOccupier: to,
		player:       p,
	}
}

func (f *frost) TakeDamage(amount int, a Attacker) {
	f.unit.TakeDamage(amount, a)
	if f.IsDead() {
		f.player.OnKnightDead(f)
	}
}

func (f *frost) Destroy() {
	f.unit.Destroy()
	f.Release()
}

func (f *frost) attackDamage() int {
	damage := f.unit.attackDamage()
	divider := 1
	for _, ratio := range f.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (f *frost) attackRange() fixed.Scalar {
	atkRange := data.Units[f.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range f.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return f.game.World().FromPixel(atkRange / divider)
}

func (f *frost) Update() {
	if f.freeze > 0 {
		f.attack = 0
		f.targetId = 0
		f.freeze--
		return
	}
	if f.cast > 0 {
		if f.cast == f.preCastDelay()+1 {
			f.doFreeze()
		}
		if f.cast > f.castDuration() {
			f.cast = 0
			f.setLayer(f.initialLayer())
		} else {
			f.cast++
		}
	} else {
		if f.attack > 0 {
			f.handleAttack()
		} else {
			t := f.target()
			if t == nil {
				f.findTargetAndAttack()
			} else {
				if f.withinRange(t) {
					f.handleAttack()
				} else {
					f.findTargetAndAttack()
				}
			}
		}
	}
}

func (f *frost) findTargetAndAttack() {
	t := f.findTarget()
	f.setTarget(t)
	if t != nil && f.withinRange(t) {
		f.handleAttack()
	}
}

func (f *frost) castDuration() int {
	return f.Skill()["castduration"].(int)
}

func (f *frost) preCastDelay() int {
	return f.Skill()["precastdelay"].(int)
}

func (f *frost) freezeDuration() int {
	return f.Skill()["freezeduration"].(int)
}

func (f *frost) SetAsLeader() {
	f.isLeader = true
	f.player.AddStatRatio("slowduration", f.Skill()["slowduration"].([]int)[f.level])
}

func (f *frost) Skill() map[string]interface{} {
	skill := data.Units[f.name]["skill"].(map[string]interface{})
	key := "wing"
	if f.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (f *frost) CastSkill(posX, posY int) bool {
	if f.cast > 0 {
		return false
	}
	f.attack = 0
	f.cast++
	f.castPosX = posX
	f.castPosY = posY
	f.setLayer(data.Casting)
	return true
}

func (f *frost) doFreeze() {
	duration := f.freezeDuration()
	radius := f.game.World().FromPixel(f.Skill()["radius"].(int))
	for _, id := range f.game.UnitIds() {
		u := f.game.FindUnit(id)
		if u.Team() == f.Team() {
			continue
		}
		castPos := fixed.Vector{
			X: f.unit.game.World().FromPixel(f.castPosX),
			Y: f.unit.game.World().FromPixel(f.castPosY),
		}
		d := u.Position().Sub(castPos).LengthSquared()
		r := u.Radius().Add(radius)
		if d < r.Mul(r) {
			u.Freeze(duration)
		}
	}
}

func (f *frost) target() Unit {
	return f.game.FindUnit(f.targetId)
}

func (f *frost) setTarget(u Unit) {
	if u == nil {
		f.targetId = 0
	} else {
		f.targetId = u.Id()
	}
}

func (f *frost) handleAttack() {
	if f.attack == f.preAttackDelay() {
		t := f.target()
		if t != nil && f.withinRange(t) {
			f.fire()
		} else {
			f.attack = 0
			return
		}
	}
	f.attack++
	if f.attack > f.attackInterval() {
		f.attack = 0
	}
}

func (f *frost) fire() {
	b := newBullet(f.targetId, f.bulletLifeTime(), f.attackDamage(), f.DamageType(), f.game)
	duration := 0
	for _, d := range f.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	f.game.AddBullet(b)
}
