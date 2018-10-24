package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type legion struct {
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

func newLegion(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "legion", p.Team(), level, posX, posY, g)
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
	return &legion{
		unit:         u,
		TileOccupier: to,
		player:       p,
	}
}

func (l *legion) TakeDamage(amount int, t AttackType) {
	l.unit.TakeDamage(amount, t)
	if l.IsDead() {
		l.player.OnKnightDead(l)
	}
}

func (l *legion) Destroy() {
	l.unit.Destroy()
	l.Release()
}

func (l *legion) attackDamage() int {
	damage := l.unit.attackDamage()
	divider := 1
	for _, ratio := range l.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (l *legion) attackRange() fixed.Scalar {
	atkRange := data.Units[l.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range l.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return l.game.World().FromPixel(atkRange / divider)
}

func (l *legion) Update() {
	if l.freeze > 0 {
		l.attack = 0
		l.targetId = 0
		l.freeze--
		return
	}
	if l.cast > 0 {
		if l.cast == l.preCastDelay()+1 {
			l.fireball()
		}
		if l.cast > l.castDuration() {
			l.cast = 0
			l.setLayer(l.initialLayer())
		} else {
			l.cast++
		}
	} else {
		if l.attack > 0 {
			l.handleAttack()
		} else {
			t := l.target()
			if t == nil {
				l.findTargetAndAttack()
			} else {
				if l.withinRange(t) {
					l.handleAttack()
				} else {
					l.findTargetAndAttack()
				}
			}
		}
	}
}

func (l *legion) findTargetAndAttack() {
	t := l.findTarget()
	l.setTarget(t)
	if t != nil && l.withinRange(t) {
		l.handleAttack()
	}
}

func (l *legion) castDuration() int {
	return l.Skill()["castduration"].(int)
}

func (l *legion) preCastDelay() int {
	return l.Skill()["precastdelay"].(int)
}

func (l *legion) SetAsLeader() {
	l.isLeader = true
	l.player.AddStatRatio("attackdamageratio", l.Skill()["attackdamageratio"].([]int)[l.level])

}

func (l *legion) Skill() map[string]interface{} {
	skill := data.Units[l.name]["skill"].(map[string]interface{})
	key := "wing"
	if l.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (l *legion) CastSkill(posX, posY int) bool {
	if l.cast > 0 {
		return false
	}
	l.attack = 0
	l.cast++
	l.castPosX = posX
	l.castPosY = posY
	l.setLayer(data.Casting)
	return true
}

func (l *legion) fireball() {
	damage := l.Skill()["damage"].([]int)[l.level]
	radius := l.game.World().FromPixel(l.Skill()["radius"].(int))
	for _, id := range l.game.UnitIds() {
		u := l.game.FindUnit(id)
		if u.Team() == l.Team() {
			continue
		}
		castPos := fixed.Vector{
			X: l.unit.game.World().FromPixel(l.castPosX),
			Y: l.unit.game.World().FromPixel(l.castPosY),
		}
		d := u.Position().Sub(castPos).LengthSquared()
		r := u.Radius().Add(radius)
		if d < r.Mul(r) {
			u.TakeDamage(damage, Skill)
		}
	}
}

func (l *legion) target() Unit {
	return l.game.FindUnit(l.targetId)
}

func (l *legion) setTarget(u Unit) {
	if u == nil {
		l.targetId = 0
	} else {
		l.targetId = u.Id()
	}
}

func (l *legion) handleAttack() {
	if l.attack == l.preAttackDelay() {
		t := l.target()
		if t != nil && l.withinRange(t) {
			l.fire()
		} else {
			l.attack = 0
			return
		}
	}
	l.attack++
	if l.attack > l.attackInterval() {
		l.attack = 0
	}
}

func (l *legion) fire() {
	b := newBullet(l.targetId, l.bulletLifeTime(), l.attackDamage(), l.game)
	duration := 0
	for _, d := range l.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	l.game.AddBullet(b)
}
