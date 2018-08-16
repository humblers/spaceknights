package game

import "github.com/humblers/spaceknights/pkg/fixed"

type judge struct {
	*unit
	player   Player
	targetId int
	attack   int
	cast     int
	initPos  fixed.Vector
	castPosX int
	castPosY int
}

func newJudge(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "judge", p.Team(), level, posX, posY, g)
	return &judge{
		unit:    u,
		player:  p,
		initPos: u.Position(),
	}
}

func (j *judge) TakeDamage(amount int, t AttackType) {
	j.unit.TakeDamage(amount, t)
	if j.IsDead() {
		j.player.OnKnightDead(j)
	}
}

func (j *judge) Update() {
	if j.cast > 0 {
		if j.cast == j.preCastDelay()+1 {
			j.bulletrain()
		}
		if j.cast > j.castDuration() {
			j.cast = 0
			j.setLayer(j.initialLayer())
		} else {
			j.cast++
		}
	} else {
		if j.attack > 0 {
			j.handleAttack()
		} else {
			t := j.target()
			if t == nil {
				j.findTargetAndAttack()
			} else {
				if j.withinRange(t) {
					j.handleAttack()
				} else {
					j.findTargetAndAttack()
				}
			}
		}
	}
}

func (j *judge) findTargetAndAttack() {
	t := j.findTarget()
	j.setTarget(t)
	if t != nil && j.withinRange(t) {
		j.handleAttack()
	}
}

func (j *judge) castDuration() int {
	return cards[j.Skill()]["castduration"].(int)
}

func (j *judge) preCastDelay() int {
	return cards[j.Skill()]["precastdelay"].(int)
}

func (j *judge) CastSkill(posX, posY int) bool {
	if j.cast > 0 {
		return false
	}
	j.attack = 0
	j.cast++
	j.castPosX = posX
	j.castPosY = posY
	j.setLayer(Casting)
	return true
}

func (j *judge) bulletrain() {
	damage := cards[j.Skill()]["damage"].([]int)[j.level]
	radius := j.game.World().FromPixel(cards[j.Skill()]["radius"].(int))
	for _, id := range j.game.UnitIds() {
		u := j.game.FindUnit(id)
		if u.Team() == j.Team() {
			continue
		}
		castPos := fixed.Vector{
			X: j.unit.game.World().FromPixel(j.castPosX),
			Y: j.unit.game.World().FromPixel(j.castPosY),
		}
		d := u.Position().Sub(castPos).LengthSquared()
		r := u.Radius().Add(radius)
		if d < r.Mul(r) {
			u.TakeDamage(damage, Skill)
		}
	}
}

func (j *judge) target() Unit {
	return j.game.FindUnit(j.targetId)
}

func (j *judge) setTarget(u Unit) {
	if u == nil {
		j.targetId = 0
	} else {
		j.targetId = u.Id()
	}
}

func (j *judge) handleAttack() {
	if j.attack == j.preAttackDelay() {
		t := j.target()
		if t != nil && j.withinRange(t) {
			j.fire()
		} else {
			j.attack = 0
			return
		}
	}
	j.attack++
	if j.attack > j.attackInterval() {
		j.attack = 0
	}
}

func (j *judge) fire() {
	b := newBullet(j.targetId, j.bulletLifeTime(), j.attackDamage())
	j.game.AddBullet(b)
}