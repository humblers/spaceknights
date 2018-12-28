package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type valkyrie struct {
	*unit
	player   Player
	isLeader bool
	targetId int
	attack   int
	cast     int
	initPos  fixed.Vector
	minPosX  fixed.Scalar
	maxPosX  fixed.Scalar
	castPosX int
	castPosY int
}

func newValkyrie(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "valkyrie", p.Team(), level, posX, posY, g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, knightTileNumX, knightTileNumY}
	u.Occupy(tr)
	offsetX := g.Map().TileWidth().Mul(fixed.FromInt(HoverKnightTileOffsetX))
	return &valkyrie{
		unit:    u,
		player:  p,
		initPos: u.Position(),
		minPosX: u.Position().X.Sub(offsetX),
		maxPosX: u.Position().X.Add(offsetX),
	}
}

func (v *valkyrie) TakeDamage(amount int, a Attacker) {
	v.unit.TakeDamage(amount, a)
	if v.IsDead() {
		v.player.OnKnightDead(v)
	}
}

func (v *valkyrie) Destroy() {
	v.unit.Destroy()
	v.Release()
}

func (v *valkyrie) attackDamage() int {
	damage := v.unit.attackDamage()
	divider := 1
	for _, ratio := range v.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (v *valkyrie) attackRange() fixed.Scalar {
	atkRange := data.Units[v.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range v.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return v.game.World().FromPixel(atkRange / divider)
}

func (v *valkyrie) Update() {
	if v.freeze > 0 {
		v.attack = 0
		v.targetId = 0
		v.freeze--
		return
	}
	if v.cast > 0 {
		if v.cast == v.preCastDelay()+1 {
			v.emp()
		}
		if v.cast > v.castDuration() {
			v.cast = 0
			v.setLayer(v.initialLayer())
		} else {
			v.cast++
		}
	} else {
		if v.attack > 0 {
			v.handleAttack()
		} else {
			t := v.target()
			if t == nil {
				v.findTargetAndDoAction()
			} else {
				if v.withinRange(t) {
					v.handleAttack()
				} else {
					v.findTargetAndDoAction()
				}
			}
		}
	}
}

func (v *valkyrie) findTargetAndDoAction() {
	t := v.findTarget()
	v.setTarget(t)
	if t != nil {
		if v.withinRange(t) {
			v.handleAttack()
		} else {
			v.moveToPos(
				fixed.Vector{
					t.Position().X.Clamp(v.minPosX, v.maxPosX),
					v.Position().Y,
				},
			)
		}
	} else {
		v.moveToPos(v.initPos) // back to init pos
	}
}

func (v *valkyrie) castDuration() int {
	return v.Skill()["castduration"].(int)
}

func (v *valkyrie) preCastDelay() int {
	return v.Skill()["precastdelay"].(int)
}

func (v *valkyrie) SetAsLeader() {
	v.isLeader = true
}

func (v *valkyrie) Skill() map[string]interface{} {
	skill := data.Units[v.name]["skill"].(map[string]interface{})
	key := "wing"
	if v.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (v *valkyrie) CanCastSkill() bool {
	return v.cast <= 0
}

func (v *valkyrie) CastSkill(posX, posY int) {
	v.attack = 0
	v.cast++
	v.castPosX = posX
	v.castPosY = posY
	v.setLayer(data.Casting)
}

func (v *valkyrie) emp() {
	damage := v.Skill()["damage"].([]int)[v.level]
	radius := v.game.World().FromPixel(v.Skill()["radius"].(int))
	for _, id := range v.game.UnitIds() {
		u := v.game.FindUnit(id)
		if u.Team() == v.Team() {
			continue
		}
		castPos := fixed.Vector{
			X: v.unit.game.World().FromPixel(v.castPosX),
			Y: v.unit.game.World().FromPixel(v.castPosY),
		}
		d := u.Position().Sub(castPos).LengthSquared()
		r := u.Radius().Add(radius)
		if d < r.Mul(r) {
			u.TakeDamage(damage, v)
		}
	}
}

func (v *valkyrie) target() Unit {
	return v.game.FindUnit(v.targetId)
}

func (v *valkyrie) setTarget(u Unit) {
	if u == nil {
		v.targetId = 0
	} else {
		v.targetId = u.Id()
	}
}

func (v *valkyrie) handleAttack() {
	if v.attack == v.preAttackDelay() {
		t := v.target()
		if t != nil && v.withinRange(t) {
			v.fire()
		} else {
			v.attack = 0
			return
		}
	}
	v.attack++
	if v.attack > v.attackInterval() {
		v.attack = 0
	}
}

func (v *valkyrie) fire() {
	b := newBullet(v.targetId, v.bulletLifeTime(), v.attackDamage(), v.DamageType(), v.game)
	duration := 0
	for _, d := range v.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	v.game.AddBullet(b)
}