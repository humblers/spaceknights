package game

import "github.com/humblers/spaceknights/pkg/fixed"

type astra struct {
	*unit
	player   Player
	isLeader bool
	targetId int
	attack   int
	cast     int
	initPos  fixed.Vector
	castPosX int
	castPosY int
}

func newAstra(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "astra", p.Team(), level, posX, posY, g)
	return &astra{
		unit:    u,
		player:  p,
		initPos: u.Position(),
	}
}

func (a *astra) TakeDamage(amount int, t AttackType) {
	a.unit.TakeDamage(amount, t)
	if a.IsDead() {
		a.player.OnKnightDead(a)
	}
}

func (a *astra) Update() {
	if a.cast > 0 {
		if a.cast > a.laserStart() && a.cast <= a.laserEnd() {
			a.deal()
		}
		if a.cast > a.laserDuration() {
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
		a.chaseTarget()
	}
}

func (a *astra) deal() {
	for _, id := range a.game.UnitIds() {
		u := a.game.FindUnit(id)
		if u.Team() == a.Team() {
			continue
		}
		if a.inLaserArea(u) {
			u.TakeDamage(a.laserDamage(), Skill)
		}
	}
}

func (a *astra) laserDuration() int {
	return cards[a.Skill()]["duration"].(int)
}

func (a *astra) laserStart() int {
	return cards[a.Skill()]["start"].(int)
}

func (a *astra) laserEnd() int {
	return cards[a.Skill()]["end"].(int)
}

func (a *astra) laserDamage() int {
	switch v := cards[a.Skill()]["damage"].(type) {
	case int:
		return v
	case []int:
		return v[a.level]
	}
	panic("invalid laser damage type")
}

func (a *astra) laserWidth() fixed.Scalar {
	return a.game.World().FromPixel(cards[a.Skill()]["width"].(int))
}

func (a *astra) laserHeight() fixed.Scalar {
	return a.game.World().FromPixel(cards[a.Skill()]["height"].(int))
}

func (a *astra) inLaserArea(u Unit) bool {
	center := fixed.Vector{
		a.game.World().FromPixel(a.castPosX),
		a.game.World().FromPixel(a.castPosY).Sub(a.laserHeight()),
	}
	if boxVSCircle(center, u.Position(), a.laserWidth(), a.laserHeight(), u.Radius()) {
		return true
	}
	return false
}

func (a *astra) chaseTarget() {
	t := a.target()
	if t != nil && a.canSee(t) {
		a.moveTo(fixed.Vector{t.Position().X, a.Position().Y})
	} else {
		a.moveTo(a.initPos)
	}
}

func (a *astra) findTargetAndAttack() {
	t := a.findTarget()
	a.setTarget(t)
	if t != nil && a.withinRange(t) {
		a.handleAttack()
	}
}

func (a *astra) SetAsLeader() {
	a.isLeader = true
	data := passives[a.Skill()]
	a.player.AddStatRatio("hpratio", data["hpratio"].([]int)[a.level])
	hp := a.initialHp()
	divider := 1
	for _, ratio := range a.player.StatRatios("hpratio") {
		hp *= ratio
		divider *= 100
	}
	a.hp = hp / divider

}

func (a *astra) Skill() string {
	key := "active"
	if a.isLeader {
		key = "passive"
	}
	return units[a.name][key].(string)
}

func (a *astra) CastSkill(posX, posY int) bool {
	if a.cast > 0 {
		return false
	}
	a.attack = 0
	a.cast++
	a.castPosX = posX
	a.castPosY = posY
	a.setLayer(Casting)
	return true
}

func (a *astra) target() Unit {
	return a.game.FindUnit(a.targetId)
}

func (a *astra) setTarget(u Unit) {
	if u == nil {
		a.targetId = 0
	} else {
		a.targetId = u.Id()
	}
}

func (a *astra) handleAttack() {
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

func (a *astra) fire() {
	b := newBullet(a.targetId, a.bulletLifeTime(), a.attackDamage())
	a.game.AddBullet(b)
}

func boxVSCircle(posA, posB fixed.Vector, width, height, radius fixed.Scalar) bool {
	relPos := posB.Sub(posA)
	closest := relPos
	xExtent := width
	yExtent := height
	closest.X = closest.X.Clamp(-xExtent, xExtent)
	closest.Y = closest.Y.Clamp(-yExtent, yExtent)
	if relPos == closest {
		return false
	}
	normal := relPos.Sub(closest)
	d := normal.LengthSquared()
	if d > radius.Mul(radius) {
		return false
	}
	return true
}
