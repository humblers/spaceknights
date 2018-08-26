package game

import "github.com/humblers/spaceknights/pkg/fixed"

type tombstone struct {
	*unit
	TileOccupier
	player        Player
	isLeader      bool
	targetId      int
	attack        int
	cast          int
	initPos       fixed.Vector
	castPosX      int
	castPosY      int
	castTile      TileOccupier
	prevDeathToll int
}

func newTombstone(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "tombstone", p.Team(), level, posX, posY, g)
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
	return &tombstone{
		unit:         u,
		TileOccupier: to,
		player:       p,
		initPos:      u.Position(),
		castTile:     newTileOccupier(g),
	}
}

func (ts *tombstone) TakeDamage(amount int, t AttackType) {
	ts.unit.TakeDamage(amount, t)
	if ts.IsDead() {
		ts.player.OnKnightDead(ts)
	}
}

func (ts *tombstone) Destroy() {
	ts.unit.Destroy()
	ts.TileOccupier.Release()
	ts.castTile.Release()
}

func (ts *tombstone) attackDamage() int {
	damage := ts.unit.attackDamage()
	divider := 1
	for _, ratio := range ts.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (ts *tombstone) attackRange() fixed.Scalar {
	atkRange := units[ts.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range ts.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return ts.game.World().FromPixel(atkRange / divider)
}

func (ts *tombstone) Update() {
	if ts.isLeader {
		data := passives[ts.Skill()]
		deathToll := ts.game.DeathToll(ts.Team())
		if deathToll != ts.prevDeathToll && deathToll%data["perdeaths"].(int) == 0 {
			ts.prevDeathToll = deathToll
			ts.spawn(data)
		}
	}
	if ts.cast > 0 {
		if ts.cast == ts.preCastDelay()+1 {
			ts.spawn(cards[ts.Skill()])
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

func (ts *tombstone) SetAsLeader() {
	ts.isLeader = true
}

func (ts *tombstone) Skill() string {
	key := "active"
	if ts.isLeader {
		key = "passive"
	}
	return units[ts.name][key].(string)
}

func (ts *tombstone) CastSkill(posX, posY int) bool {
	if ts.cast > 0 {
		return false
	}

	name := cards[ts.Skill()]["unit"].(string)
	nx := units[name]["tilenumx"].(int)
	ny := units[name]["tilenumy"].(int)
	tx, ty := ts.game.TileFromPos(posX, posY)
	tr := ts.castTile.GetRect(tx, ty, nx, ny)
	if err := ts.castTile.Occupy(tr); err != nil {
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

func (ts *tombstone) spawn(data map[string]interface{}) {
	name := data["unit"].(string)
	if name == "barrack" {
		id := ts.game.AddUnit(name, ts.level, ts.castPosX, ts.castPosY, ts.player)
		tr := ts.castTile.Occupied()
		ts.castTile.Release()
		if occupier, ok := ts.game.FindUnit(id).(TileOccupier); ok {
			if err := occupier.Occupy(tr); err != nil {
				panic(err)
			}
		}
	}
	if name == "footman" {
		deadPosX := ts.game.LastDeadPosX(ts.Team())
		offsetX := data["offsetX"].(int)
		if ts.game.Map().Width().Div(fixed.Two) > deadPosX {
			offsetX *= -1
		}
		posX := ts.game.World().ToPixel(ts.initPos.X) + offsetX
		posY := ts.game.World().ToPixel(ts.initPos.Y)
		ts.game.AddUnit(name, ts.level, posX, posY, ts.player)
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
