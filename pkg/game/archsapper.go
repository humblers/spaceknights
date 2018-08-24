package game

import "github.com/humblers/spaceknights/pkg/fixed"

type archsapper struct {
	*unit
	TileOccupier
	player   Player
	isLeader bool
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
		unit:         u,
		TileOccupier: newTileOccupier(g),
		player:       p,
		initPos:      u.Position(),
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

func (a *archsapper) SetAsLeader() {
	a.isLeader = true

	data := passives[a.Skill()]
	name := data["unit"].(string)
	count := data["count"].(int)
	xArr := data["posX"].([]int)
	yArr := data["posY"].([]int)

	nx := units[name]["tilenumx"].(int)
	ny := units[name]["tilenumy"].(int)
	for i := 0; i < count; i++ {
		posX, posY := xArr[i], yArr[i]
		if a.player.Team() == Red {
			posX, posY = a.game.FlipX(posX), a.game.FlipY(posY)
		}
		id := a.game.AddUnit(name, a.level, posX, posY, a.player)
		unit := a.game.FindUnit(id)
		if cannon, ok := unit.(cannon); ok {
			tx, ty := a.game.TileFromPos(posX, posY)
			tr := cannon.GetRect(tx, ty, nx, ny)
			if err := cannon.Occupy(tr); err != nil {
				panic(err)
			}
			cannon.SetDecayOff()
			bonusHp := cannon.initialHp() * data["mulhp"].([]int)[a.level] / 100
			cannon.addHp(bonusHp)
		}
	}
}

func (a *archsapper) Skill() string {
	key := "active"
	if a.isLeader {
		key = "passive"
	}
	return units[a.name][key].(string)
}

func (a *archsapper) CastSkill(posX, posY int) bool {
	if a.cast > 0 {
		return false
	}

	name := cards[a.Skill()]["unit"].(string)
	nx := units[name]["tilenumx"].(int)
	ny := units[name]["tilenumy"].(int)
	tx, ty := a.game.TileFromPos(posX, posY)
	tr := a.GetRect(tx, ty, nx, ny)
	if err := a.Occupy(tr); err != nil {
		a.game.Logger().Print(err)
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
	name := cards[a.Skill()]["unit"].(string)
	id := a.game.AddUnit(name, a.level, a.castPosX, a.castPosY, a.player)
	tr := a.Occupied()
	a.Release()
	if occupier, ok := a.game.FindUnit(id).(TileOccupier); ok {
		if err := occupier.Occupy(tr); err != nil {
			panic(err)
		}
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
