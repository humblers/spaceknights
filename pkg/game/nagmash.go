package game

import "github.com/humblers/spaceknights/pkg/fixed"

type nagmash struct {
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
}

func newNagmash(id int, level, posX, posY int, g Game, p Player) Unit {
	u := newUnit(id, "nagmash", p.Team(), level, posX, posY, g)
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
	return &nagmash{
		unit:         u,
		TileOccupier: to,
		player:       p,
		initPos:      u.Position(),
		minPosX:      u.Position().X.Sub(offsetX),
		maxPosX:      u.Position().X.Add(offsetX),
	}
}

func (n *nagmash) TakeDamage(amount int, t AttackType) {
	n.unit.TakeDamage(amount, t)
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
	return damage / divider
}

func (n *nagmash) attackRange() fixed.Scalar {
	atkRange := units[n.name]["attackrange"].(int)
	divider := 1
	for _, ratio := range n.player.StatRatios("attackrangeratio") {
		atkRange *= ratio
		divider *= 100
	}
	return n.game.World().FromPixel(atkRange / divider)
}

func (n *nagmash) Update() {
	if n.isLeader {
		data := passives[n.Skill()]
		if n.game.Step()%data["perstep"].(int) == 0 {
			posX := n.game.World().ToPixel(n.initPos.X)
			posY := n.game.World().ToPixel(n.initPos.Y)
			n.spawn(data, posX, posY)
		}
	}
	if n.cast > 0 {
		if n.cast == n.preCastDelay()+1 {
			n.spawn(cards[n.Skill()], n.castPosX, n.castPosY)
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
			n.moveTo(fixed.Vector{posX, n.Position().Y})
			if n.withinRange(t) {
				if n.attack%n.attackInterval() == 0 {
					t.TakeDamage(n.attackDamage(), Range)
					duration := 0
					for _, d := range n.player.StatRatios("slowduration") {
						duration += d
					}
					t.MakeSlow(duration)
				}
				n.attack++
			} else {
				n.attack = 0
			}
		} else {
			n.moveTo(n.initPos)
			n.attack = 0
		}
	}
}

func (n *nagmash) castDuration() int {
	return cards[n.Skill()]["castduration"].(int)
}

func (n *nagmash) preCastDelay() int {
	return cards[n.Skill()]["precastdelay"].(int)
}

func (n *nagmash) SetAsLeader() {
	n.isLeader = true
}

func (n *nagmash) Skill() string {
	key := "active"
	if n.isLeader {
		key = "passive"
	}
	return units[n.name][key].(string)
}

func (n *nagmash) CastSkill(posX, posY int) bool {
	if n.cast > 0 {
		return false
	}
	n.attack = 0
	n.cast++
	n.castPosX = posX
	n.castPosY = posY
	n.setLayer(Casting)
	return true
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
