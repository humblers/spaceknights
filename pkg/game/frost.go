package game

import "github.com/humblers/spaceknights/pkg/fixed"

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

func (f *frost) TakeDamage(amount int, t AttackType) {
	f.unit.TakeDamage(amount, t)
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
	atkRange := units[f.name]["attackrange"].(int)
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
	return cards[f.Skill()]["castduration"].(int)
}

func (f *frost) preCastDelay() int {
	return cards[f.Skill()]["precastdelay"].(int)
}

func (f *frost) SetAsLeader() {
	f.isLeader = true
	data := passives[f.Skill()]
	f.player.AddStatRatio("slowduration", data["slowduration"].([]int)[f.level])

}

func (f *frost) Skill() string {
	key := "active"
	if f.isLeader {
		key = "passive"
	}
	return units[f.name][key].(string)
}

func (f *frost) CastSkill(posX, posY int) bool {
	if f.cast > 0 {
		return false
	}
	f.attack = 0
	f.cast++
	f.castPosX = posX
	f.castPosY = posY
	f.setLayer(Casting)
	return true
}

func (f *frost) doFreeze() {
	duration := f.castDuration() - f.preCastDelay()
	radius := f.game.World().FromPixel(cards[f.Skill()]["radius"].(int))
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
	b := newBullet(f.targetId, f.bulletLifeTime(), f.attackDamage(), f.game)
	duration := 0
	for _, d := range f.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	f.game.AddBullet(b)
}
