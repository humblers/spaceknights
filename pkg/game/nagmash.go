package game

import "github.com/humblers/spaceknights/pkg/fixed"

type nagmash struct {
	*unit
	player   Player
	isLeader bool
	targetId int
	attack   int
	cast     int
	initPos  fixed.Vector
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
	return &nagmash{
		unit:    u,
		player:  p,
		initPos: u.Position(),
	}
}

func (n *nagmash) TakeDamage(amount int, t AttackType) {
	n.unit.TakeDamage(amount, t)
	if n.IsDead() {
		n.player.OnKnightDead(n)
	}
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
		if n.attack > 0 {
			n.handleAttack()
		} else {
			t := n.target()
			if t == nil {
				n.findTargetAndAttack()
			} else {
				if n.withinRange(t) {
					n.handleAttack()
				} else {
					n.findTargetAndAttack()
				}
			}
		}
		n.chaseTarget()
	}
}

func (n *nagmash) chaseTarget() {
	t := n.target()
	if t != nil && n.canSee(t) {
		n.moveTo(fixed.Vector{t.Position().X, n.Position().Y})
	} else {
		n.moveTo(n.initPos)
	}
}

func (n *nagmash) castDuration() int {
	return cards[n.Skill()]["castduration"].(int)
}

func (n *nagmash) preCastDelay() int {
	return cards[n.Skill()]["precastdelay"].(int)
}

func (n *nagmash) findTargetAndAttack() {
	t := n.findTarget()
	n.setTarget(t)
	if t != nil && n.withinRange(t) {
		n.handleAttack()
	}
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

func (n *nagmash) handleAttack() {
	if n.attack == n.preAttackDelay() {
		t := n.target()
		if t != nil && n.withinRange(t) {
			n.fire()
		} else {
			n.attack = 0
			return
		}
	}
	n.attack++
	if n.attack > n.attackInterval() {
		n.attack = 0
	}
}

func (n *nagmash) fire() {
	b := newBullet(n.targetId, n.bulletLifeTime(), n.attackDamage())
	n.game.AddBullet(b)
}
