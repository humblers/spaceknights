package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type judge struct {
	*unit
	player   Player
	isLeader bool
	targetId int
	attack   int
	cast     int
	castPosX int
	castPosY int
}

func newJudge(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "judge", p.Team(), level, posX, posY, g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, knightTileNumX, knightTileNumY}
	u.Occupy(tr)
	return &judge{
		unit:   u,
		player: p,
	}
}

func (j *judge) TakeDamage(amount int, a Attacker) {
	j.unit.TakeDamage(amount, a)
	if j.IsDead() {
		j.player.OnKnightDead(j)
	}
}

func (j *judge) Destroy() {
	j.unit.Destroy()
	j.Release()
}

func (j *judge) DamageType() data.DamageType {
	if j.cast > 0 {
		return j.Skill()["damagetype"].(data.DamageType)
	}
	return j.unit.DamageType()
}

func (j *judge) attackDamage() int {
	damage := j.unit.attackDamage()
	divider := 1
	for _, ratio := range j.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (j *judge) attackRange() fixed.Scalar {
	atkRange := data.Units[j.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range j.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return j.game.World().FromPixel(atkRange / divider)
}

func (j *judge) Update() {
	if j.freeze > 0 {
		j.attack = 0
		j.targetId = 0
		j.freeze--
		return
	}
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
	return j.Skill()["castduration"].(int)
}

func (j *judge) preCastDelay() int {
	return j.Skill()["precastdelay"].(int)
}

func (j *judge) SetAsLeader() {
	j.isLeader = true
	j.player.AddStatRatio("attackrangeratio", j.Skill()["attackrangeratio"].([]int)[j.level])
}

func (j *judge) Skill() map[string]interface{} {
	skill := data.Units[j.name]["skill"].(map[string]interface{})
	key := "wing"
	if j.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (j *judge) CanCastSkill() bool {
	return j.cast <= 0
}

func (j *judge) CastSkill(posX, posY int) {
	j.attack = 0
	j.cast++
	j.castPosX = posX
	j.castPosY = posY
	j.setLayer(data.Casting)
}

func (j *judge) bulletrain() {
	damage := j.Skill()["damage"].([]int)[j.level]
	radius := j.game.World().FromPixel(j.Skill()["radius"].(int))
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
			u.TakeDamage(damage, j)
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
	b := newBullet(j.targetId, j.bulletLifeTime(), j.attackDamage(), j.DamageType(), j.game)
	duration := 0
	for _, d := range j.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	j.game.AddBullet(b)
}
