package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type tombstone struct {
	*unit
	TileOccupier
	player        Player
	isLeader      bool
	targetId      int
	attack        int
	cast          int
	initPos       fixed.Vector
	minPosX       fixed.Scalar
	maxPosX       fixed.Scalar
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
	offsetX := g.Map().TileWidth().Mul(fixed.FromInt(HoverKnightTileOffsetX))
	return &tombstone{
		unit:         u,
		TileOccupier: to,
		player:       p,
		initPos:      u.Position(),
		minPosX:      u.Position().X.Sub(offsetX),
		maxPosX:      u.Position().X.Add(offsetX),
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
	atkRange := data.Units[ts.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range ts.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return ts.game.World().FromPixel(atkRange / divider)
}

func (ts *tombstone) Update() {
	if ts.isLeader {
		deathToll := ts.game.DeathToll(ts.Team())
		if deathToll != ts.prevDeathToll && deathToll%ts.Skill()["perdeaths"].(int) == 0 {
			ts.prevDeathToll = deathToll
			ts.spawn(ts.Skill())
		}
	}
	if ts.freeze > 0 {
		ts.attack = 0
		ts.targetId = 0
		ts.freeze--
		return
	}
	if ts.cast > 0 {
		if ts.cast == ts.preCastDelay()+1 {
			ts.spawn(ts.Skill())
		}
		if ts.cast > ts.castDuration() {
			ts.cast = 0
			ts.setLayer(ts.initialLayer())
		} else {
			ts.cast++
		}
	} else {
		if ts.target() == nil {
			ts.setTarget(ts.findTarget())
			ts.attack = 0
		}
		t := ts.target()
		if t != nil && ts.canSee(t) {
			posX := t.Position().X
			if posX < ts.minPosX {
				posX = ts.minPosX
			} else if posX > ts.maxPosX {
				posX = ts.maxPosX
			}
			ts.moveToPos(fixed.Vector{posX, ts.Position().Y})
			if ts.withinRange(t) {
				if ts.attack%ts.attackInterval() == 0 {
					t.TakeDamage(ts.attackDamage(), Range)
					duration := 0
					for _, d := range ts.player.StatRatios("slowduration") {
						duration += d
					}
					t.MakeSlow(duration)
				}
				ts.attack++
			} else {
				ts.attack = 0
			}
		} else {
			ts.moveToPos(ts.initPos)
			ts.attack = 0
		}
	}
}

func (ts *tombstone) castDuration() int {
	return ts.Skill()["castduration"].(int)
}

func (ts *tombstone) preCastDelay() int {
	return ts.Skill()["precastdelay"].(int)
}

func (ts *tombstone) SetAsLeader() {
	ts.isLeader = true
}

func (ts *tombstone) Skill() map[string]interface{} {
	skill := data.Units[ts.name]["skill"].(map[string]interface{})
	key := "wing"
	if ts.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (ts *tombstone) CastSkill(posX, posY int) bool {
	if ts.cast > 0 {
		return false
	}

	name := ts.Skill()["unit"].(string)
	nx := data.Units[name]["tilenumx"].(int)
	ny := data.Units[name]["tilenumy"].(int)
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
	ts.setLayer(data.Casting)
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
