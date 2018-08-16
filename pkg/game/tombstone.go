package game

import "github.com/humblers/spaceknights/pkg/fixed"

type tombstone struct {
	*unit
	TileOccupier
	player   Player
	targetId int
	attack   int
	cast     int
	initPos  fixed.Vector
	castPosX int
	castPosY int
}

func newTombstone(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "tombstone", p.Team(), level, posX, posY, g)
	return &tombstone{
		unit:         u,
		TileOccupier: newTileOccupier(g),
		player:       p,
		initPos:      u.Position(),
	}
}

func (ts *tombstone) TakeDamage(amount int, t AttackType) {
	ts.unit.TakeDamage(amount, t)
	if ts.IsDead() {
		ts.player.OnKnightDead(ts)
	}
}

func (ts *tombstone) Update() {
	if ts.cast > 0 {
		if ts.cast == ts.preCastDelay()+1 {
			ts.spawn()
		}
		if ts.cast > ts.castDuration() {
			ts.cast = 0
			ts.setLayer(ts.initialLayer())
		} else {
			ts.cast++
		}
	} else {
		if ts.attack > 0 {
			ts.handleAttack()
		} else {
			t := ts.target()
			if t == nil {
				ts.findTargetAndAttack()
			} else {
				if ts.withinRange(t) {
					ts.handleAttack()
				} else {
					ts.findTargetAndAttack()
				}
			}
		}
	}
}

func (ts *tombstone) castDuration() int {
	return cards[ts.Skill()]["castduration"].(int)
}

func (ts *tombstone) preCastDelay() int {
	return cards[ts.Skill()]["precastdelay"].(int)
}

func (ts *tombstone) findTargetAndAttack() {
	t := ts.findTarget()
	ts.setTarget(t)
	if t != nil && ts.withinRange(t) {
		ts.handleAttack()
	}
}

func (ts *tombstone) CastSkill(posX, posY int) bool {
	if ts.cast > 0 {
		return false
	}

	name := cards[ts.Skill()]["spawn"].(string)
	nx := units[name]["tilenumx"].(int)
	ny := units[name]["tilenumy"].(int)
	tx, ty := ts.game.TileFromPos(posX, posY)
	tr := ts.GetRect(tx, ty, nx, ny)
	if err := ts.Occupy(tr); err != nil {
		ts.game.Logger().Print(err)
		return false
	}

	ts.attack = 0
	ts.cast++
	ts.castPosX = posX
	ts.castPosY = posY
	ts.setLayer(Casting)
	return true
}

func (ts *tombstone) spawn() {
	name := cards[ts.Skill()]["spawn"].(string)
	id := ts.game.AddUnit(name, ts.level, ts.castPosX, ts.castPosY, ts.player)
	tr := ts.Occupied()
	ts.Release()
	if occupier, ok := ts.game.FindUnit(id).(TileOccupier); ok {
		if err := occupier.Occupy(tr); err != nil {
			panic(err)
		}
	}
}

func (ts *tombstone) target() Unit {
	return ts.game.FindUnit(ts.targetId)
}

func (ts *tombstone) setTarget(u Unit) {
	if u == nil {
		ts.targetId = 0
	} else {
		ts.targetId = u.Id()
	}
}

func (ts *tombstone) handleAttack() {
	if ts.attack == ts.preAttackDelay() {
		t := ts.target()
		if t != nil && ts.withinRange(t) {
			ts.fire()
		} else {
			ts.attack = 0
			return
		}
	}
	ts.attack++
	if ts.attack > ts.attackInterval() {
		ts.attack = 0
	}
}

func (ts *tombstone) fire() {
	b := newBullet(ts.targetId, ts.bulletLifeTime(), ts.attackDamage())
	ts.game.AddBullet(b)
}
