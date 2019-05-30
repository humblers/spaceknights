package game

import (
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
)

type nagmash struct {
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

func newNagmash(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "nagmash", p.Team(), level, posX, posY, g)
	tx, ty := g.TileFromPos(posX, posY)
	tr := &tileRect{tx, ty, knightTileNumX, knightTileNumY}
	u.Occupy(tr)
	offsetX := g.Map().TileWidth().Mul(fixed.FromInt(HoverKnightTileOffsetX))
	return &nagmash{
		unit:    u,
		player:  p,
		initPos: u.Position(),
		minPosX: u.Position().X.Sub(offsetX),
		maxPosX: u.Position().X.Add(offsetX),
	}
}

func (n *nagmash) TakeDamage(amount int, damageType data.DamageType) {
	if damageType.Is(data.DecreaseOnKnight) {
		amount = amount * data.DecreasedDamageRatioOnKnightBuilding / 100
	}
	n.unit.TakeDamage(amount, damageType)
	if n.IsDead() {
		n.player.OnKnightDead(n)
	}
}

func (n *nagmash) Destroy() {
	n.unit.Destroy()
	n.Release()
}

func (n *nagmash) attackDamage() int {
	damage := n.unit.attackDamage()
	divider := 1
	for _, ratio := range n.player.StatRatios("attackdamageratio") {
		damage *= ratio
		divider *= 100
	}
	damage /= divider
	limits := n.player.StatRatios("amplifycountlimit")
	for i, amplify := range n.player.StatRatios("amplifydamagepersec") {
		cnt := n.attack / data.StepPerSec
		if cnt > limits[i] {
			cnt = limits[i]
		}
		damage += amplify * cnt * n.attackInterval() / data.StepPerSec
	}
	return damage
}

func (n *nagmash) attackRange() fixed.Scalar {
	atkRange := data.Units[n.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range n.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return n.game.World().FromPixel(atkRange / divider)
}

func (n *nagmash) Update() {
	if n.freeze > 0 {
		n.attack = 0
		n.targetId = 0
		n.freeze--
		return
	}
	step := n.game.Step() - data.InitialLeaderSpawnDelay
	if n.isLeader && step >= 0 && step%n.Skill()["perstep"].(int) == 0 {
		posX := n.game.World().ToPixel(n.initPos.X)
		posY := n.game.World().ToPixel(n.initPos.Y)
		n.spawn(n.Skill(), posX, posY)
	}
	if n.cast > 0 {
		if n.cast == n.preCastDelay()+1 {
			n.spawn(n.Skill(), n.castPosX, n.castPosY)
		}
		if n.cast > n.castDuration() {
			n.cast = 0
			n.setLayer(n.initialLayer())
		} else {
			n.cast++
		}
	} else {
		if n.target() == nil {
			n.setTarget(n.findTarget())
			n.attack = 0
		}
		t := n.target()
		if t != nil && n.canSee(t) {
			posX := t.Position().X
			if posX < n.minPosX {
				posX = n.minPosX
			} else if posX > n.maxPosX {
				posX = n.maxPosX
			}
			n.moveToPos(fixed.Vector{posX, n.Position().Y})
			if n.withinRange(t) {
				if n.attack%n.attackInterval() == 0 {
					duration := 0
					for _, d := range n.player.StatRatios("slowduration") {
						duration += d
					}
					var damageRadius fixed.Scalar = 0
					for _, r := range n.player.StatRatios("expanddamageradius") {
						damageRadius = damageRadius.Add(n.game.World().FromPixel(r))
					}
					if damageRadius == 0 { // normal
						t.TakeDamage(n.attackDamage(), n.damageType())
						t.MakeSlow(duration)
					} else { // splash
						for _, id := range n.game.UnitIds() {
							u := n.game.FindUnit(id)
							if u.Team() == n.Team() {
								continue
							}
							d := t.Position().Sub(u.Position()).LengthSquared()
							r := u.Radius().Add(damageRadius)
							if d < r.Mul(r) {
								u.TakeDamage(n.attackDamage(), n.damageType())
								u.MakeSlow(duration)
							}
						}
					}
				}
				n.attack++
			} else {
				n.attack = 0
			}
		} else {
			n.moveToPos(n.initPos)
			n.attack = 0
		}
	}
}

func (n *nagmash) castDuration() int {
	return n.Skill()["castduration"].(int)
}

func (n *nagmash) preCastDelay() int {
	return n.Skill()["precastdelay"].(int)
}

func (n *nagmash) SetAsLeader() {
	n.isLeader = true
}

func (n *nagmash) Skill() map[string]interface{} {
	skill := data.Units[n.name]["skill"].(map[string]interface{})
	key := "wing"
	if n.isLeader {
		key = "leader"
	}
	return skill[key].(map[string]interface{})
}

func (n *nagmash) CanCastSkill() bool {
	return n.cast <= 0
}

func (n *nagmash) CastSkill(posX, posY int) {
	n.attack = 0
	n.cast++
	n.castPosX = posX
	n.castPosY = posY
	n.setLayer(data.Casting)
}

func (n *nagmash) spawn(data map[string]interface{}, posX, posY int) {
	name := data["unit"].(string)
	count := data["count"].(int)
	offsetX := data["offsetX"].([]int)
	offsetY := data["offsetY"].([]int)
	for i := 0; i < count; i++ {
		n.game.AddUnit(name, n.level, posX+offsetX[i], posY+offsetY[i], n.player)
	}
}

func (n *nagmash) target() Unit {
	return n.game.FindUnit(n.targetId)
}

func (n *nagmash) setTarget(u Unit) {
	if u == nil {
		n.targetId = 0
	} else {
		n.targetId = u.Id()
	}
}
