package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type ironcoffin struct {
	*unit
	TileOccupier
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
	castTile TileOccupier
}

func newIroncoffin(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "ironcoffin", p.Team(), level, posX, posY, g)
	to := newTileOccupier(g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{t: ty - 2, b: ty + 1, l: tx - 2, r: tx + 1}
	if err := to.Occupy(tr); err != nil {
		panic(err)
	}
	offsetX := g.Map().TileWidth().Mul(fixed.FromInt(HoverKnightTileOffsetX))
	return &ironcoffin{
		unit:         u,
		TileOccupier: to,
		player:       p,
		initPos:      u.Position(),
		minPosX:      u.Position().X.Sub(offsetX),
		maxPosX:      u.Position().X.Add(offsetX),
		castTile:     newTileOccupier(g),
	}
}

func (i *ironcoffin) TakeDamage(amount int, a Attacker) {
	i.unit.TakeDamage(amount, a)
	if i.IsDead() {
		i.player.OnKnightDead(i)
	}
}

func (i *ironcoffin) Destroy() {
	i.unit.Destroy()
	i.TileOccupier.Release()
	i.castTile.Release()
}

func (i *ironcoffin) attackDamage() int {
	damage := i.unit.attackDamage()
	divider := 1
	for _, ratio := range i.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	return damage / divider
}

func (i *ironcoffin) attackRange() fixed.Scalar {
	atkRange := data.Units[i.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range i.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return i.game.World().FromPixel(atkRange / divider)
}

func (i *ironcoffin) Update() {
	if i.isLeader {
		if i.game.Step()%i.Skill()["perstep"].(int) == 0 {
			i.spawn(i.Skill())
		}
	}
	if i.freeze > 0 {
		i.attack = 0
		i.targetId = 0
		i.freeze--
		return
	}
	if i.cast > 0 {
		if i.cast == i.preCastDelay()+1 {
			i.spawn(i.Skill())
		}
		if i.cast > i.castDuration() {
			i.cast = 0
			i.setLayer(i.initialLayer())
		} else {
			i.cast++
		}
	} else {
		if i.attack > 0 {
			i.handleAttack()
		} else {
			t := i.target()
			if t == nil {
				i.findTargetAndDoAction()
			} else {
				if i.withinRange(t) {
					i.handleAttack()
				} else {
					i.findTargetAndDoAction()
				}
			}
		}
	}
}

func (i *ironcoffin) findTargetAndDoAction() {
	t := i.findTarget()
	i.setTarget(t)
	if t != nil {
		if i.withinRange(t) {
			i.handleAttack()
		} else {
			i.moveToPos(
				fixed.Vector{
					t.Position().X.Clamp(i.minPosX, i.maxPosX),
					i.Position().Y,
				},
			)
		}
	} else {
		i.moveToPos(i.initPos) // back to init pos
	}
}

func (i *ironcoffin) castDuration() int {
	return i.Skill()["castduration"].(int)
}

func (i *ironcoffin) preCastDelay() int {
	return i.Skill()["precastdelay"].(int)
}

func (i *ironcoffin) SetAsLeader() {
	i.isLeader = true
}

func (i *ironcoffin) Skill() map[string]interface{} {
	skill := data.Units[i.name]["skill"].(map[string]interface{})
	key := "wing"
	if i.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (i *ironcoffin) CastSkill(posX, posY int) bool {
	if i.cast > 0 {
		return false
	}

	name := i.Skill()["unit"].(string)
	nx := data.Units[name]["tilenumx"].(int)
	ny := data.Units[name]["tilenumy"].(int)
	tx, ty := i.game.TileFromPos(posX, posY)
	tr := i.castTile.GetRect(tx, ty, nx, ny)
	if err := i.castTile.Occupy(tr); err != nil {
		i.game.Logger().Print(err)
		return false
	}

	i.attack = 0
	i.cast++
	i.castPosX = posX
	i.castPosY = posY
	i.setLayer(data.Casting)
	return true
}

func (i *ironcoffin) spawn(data map[string]interface{}) {
	name := data["unit"].(string)
	if name == "sentryshelter" {
		unit := i.game.AddUnit(name, i.level, i.castPosX, i.castPosY, i.player)
		tr := i.castTile.Occupied()
		i.castTile.Release()
		if occupier, ok := unit.(TileOccupier); ok {
			if err := occupier.Occupy(tr); err != nil {
				panic(err)
			}
		}
	}
	if name == "sentry" {
		posX := i.game.World().ToPixel(i.initPos.X)
		posY := i.game.World().ToPixel(i.initPos.Y)
		i.game.AddUnit(name, i.level, posX, posY, i.player)
	}
}

func (i *ironcoffin) target() Unit {
	return i.game.FindUnit(i.targetId)
}

func (i *ironcoffin) setTarget(u Unit) {
	if u == nil {
		i.targetId = 0
	} else {
		i.targetId = u.Id()
	}
}

func (i *ironcoffin) handleAttack() {
	if i.attack == i.preAttackDelay() {
		t := i.target()
		if t != nil && i.withinRange(t) {
			i.fire()
		} else {
			i.attack = 0
			return
		}
	}
	i.attack++
	if i.attack > i.attackInterval() {
		i.attack = 0
	}
}

func (i *ironcoffin) fire() {
	b := newBullet(i.targetId, i.bulletLifeTime(), i.attackDamage(), i.DamageType(), i.game)
	duration := 0
	for _, d := range i.player.StatRatios("slowduration") {
		duration += d
	}
	b.MakeFrozen(duration)
	i.game.AddBullet(b)
}
