package game

import "github.com/humblers/spaceknights/pkg/fixed"

type archsapper struct {
	*unit
	player   Player
	targetId int
	attack   int
	cast     int
	initPos  fixed.Vector
	castPosX int
	castPosY int
}

func newArchsapper(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "archsapper", p.Team(), level, posX, posY, g)
	return &archsapper{
		unit:    u,
		player:  p,
		initPos: u.Position(),
	}
}

func (a *archsapper) TakeDamage(amount int, t AttackType) {
	a.unit.TakeDamage(amount, t)
	if a.IsDead() {
		a.player.OnKnightDead(a)
	}
}

func (a *archsapper) Update() {
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
	return cards[a.Skill()]["castduration"].(int)
}

func (a *archsapper) preCastDelay() int {
	return cards[a.Skill()]["precastdelay"].(int)
}

func (a *archsapper) findTargetAndAttack() {
	t := a.findTarget()
	a.setTarget(t)
	if t != nil && a.withinRange(t) {
		a.handleAttack()
	}
}

func (a *archsapper) CastSkill(posX, posY int) bool {
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

func (a *archsapper) spawn() {
	card := cards[a.Skill()]["spawn"].(map[string]interface{})
	name := card["unit"].(string)
	count := card["count"].(int)
	offsetX := card["offsetX"].([]int)
	offsetY := card["offsetY"].([]int)
	for i := 0; i < count; i++ {
		a.game.AddUnit(name, a.level, a.castPosX+offsetX[i], a.castPosY+offsetY[i], a.player)
	}
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
	b := newBullet(a.targetId, a.bulletLifeTime(), a.attackDamage())
	a.game.AddBullet(b)
}
