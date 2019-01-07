package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type legion struct {
	*unit
	player      Player
	isLeader    bool
	targetId    int
	attack      int
	cast        int
	castPosX    int
	castPosY    int
	retargeting bool
}

func newLegion(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "legion", p.Team(), level, posX, posY, g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, knightTileNumX, knightTileNumY}
	u.Occupy(tr)
	return &legion{
		unit:   u,
		player: p,
	}
}

func (l *legion) TakeDamage(amount int, damageType data.DamageType) {
	if damageType == data.Skill || damageType == data.Death {
		amount = amount * data.ReducedDamgeRatioOnKnightBuilding / 100
	}
	l.unit.TakeDamage(amount, damageType)
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
	damage /= divider
	limits := l.player.StatRatios("amplifycountlimit")
	for i, amplify := range l.player.StatRatios("amplifydamagepersec") {
		cnt := l.attack / data.StepPerSec
		if cnt > limits[i] {
			cnt = limits[i]
		}
		damage += amplify * cnt * l.attackInterval() / data.StepPerSec
	}
	return damage
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
		if l.attack > 0 && !l.retargeting {
			l.handleAttack()
		} else {
			t := l.target()
			if t == nil {
				l.attack = 0
				l.findTargetAndAttack()
			} else {
				if l.withinRange(t) {
					l.handleAttack()
				} else {
					l.attack = 0
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

func (l *legion) CanCastSkill() bool {
	return l.cast <= 0
}

func (l *legion) CastSkill(posX, posY int) {
	l.attack = 0
	l.cast++
	l.castPosX = posX
	l.castPosY = posY
	l.setLayer(data.Casting)
}

func (l *legion) fireball() {
	damage := l.Skill()["damage"].([]int)[l.level]
	damageType := l.Skill()["damagetype"].(data.DamageType)
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
			u.TakeDamage(damage, damageType)
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
	modulo := l.attack % l.attackInterval()
	if modulo == l.preAttackDelay() {
		t := l.target()
		if t != nil && l.withinRange(t) {
			l.fire()
		} else {
			l.retargeting = true
			return
		}
	}
	l.retargeting = l.attack > 0 && modulo == 0
	l.attack++
}

func (l *legion) fire() {
	b := newBullet(l.targetId, l.bulletLifeTime(), l.attackDamage(), l.damageType(), l.game)
	duration := 0
	for _, d := range l.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	var damageRadius fixed.Scalar = 0
	for _, r := range l.player.StatRatios("expanddamageradius") {
		damageRadius = damageRadius.Add(l.game.World().FromPixel(r))
	}
	b.MakeSplash(damageRadius)
	l.game.AddBullet(b)
}
