package main

import "log"

type State string
const (
    Idle State = "idle"
    Attack State = "attack"
    Move State = "move"
)

type Unit struct {
    // invariant
    Team Team
    Type string `json:"-"`
    Name string
    Layer Layer
    TargetLayers []Layer `json:"-"`
    Hp int
    Speed float64 `json:"-"`
    PreHitDelay int `json:"-"`
    PostHitDelay int `json:"-"`
    Radius float64 `json:"-"`
    Sight float64 `json:"-"`
    Range float64 `json:"-"`
    Damage int `json:"-"`
    LifetimeCost int `json:"-"`

    // variant
    Id int `json:"-"`
    Game *Game `json:"-"`
    State State
    Position Vector2
    Velocity Vector2 `json:"-"`
    Target *Unit `json:"-"`
    HitFrame int `json:"-"`
}

func (u *Unit) FlipY() {
    u.Position.Y = MapHeight - u.Position.Y
}

func (u *Unit) TakeDamage(d int) {
    if u.Hp -= d; u.Hp <= 0 {
        delete(u.Game.Units, u.Id)
    }
}

func (u *Unit) Attackable(target *Unit) bool {
    if u.Team == target.Team {
        return false
    }
    switch target.Type {
    case "knight":
        return false
    case "mothership":
        if u.Name == "base" {
            return false
        }
    }
    for i := 0; i < len(u.TargetLayers); i++ {
        if u.TargetLayers[i] == target.Layer {
            return true
        }
    }
    return false
}

func (u *Unit) DistanceTo(other *Unit) float64 {
    return u.Position.Minus(other.Position).Length()
}


func (u *Unit) MoveTo(target *Unit) {
    direction := target.Position.Minus(u.Position).Normalize()
    u.Position = u.Position.Plus(direction.Multiply(u.Speed))
}

func (u *Unit) CanSee(other *Unit) bool {
    if u.DistanceTo(other) < u.Sight {
        return true
    }
    return false
}

func (u *Unit) CanAttack(other *Unit) bool {
    if u.DistanceTo(other) < u.Range {
        return true
    }
    return false
}

func (u *Unit) IsAttacking() bool {
    return u.Game.Frame >= u.HitFrame - u.PreHitDelay &&
            u.Game.Frame <= u.HitFrame + u.PostHitDelay
}

func (u *Unit) HandleAttack() {
    if u.Game.Frame == u.HitFrame {
        if u.CanAttack(u.Target) {
            u.Target.TakeDamage(u.Damage)
        }
    }
}

func (u *Unit) StartAttack() {
    u.HitFrame = u.Game.Frame + u.PreHitDelay
    u.HandleAttack()
}

func (u *Unit) FindNearestEnemy() *Unit {
    var enemy *Unit
    for _, unit := range u.Game.Units {
        if !u.Attackable(unit) {
            continue
        }
        if unit.Type == "mothership" || u.CanSee(unit) {
            if enemy == nil || u.DistanceTo(enemy) > u.DistanceTo(unit) {
                enemy = unit
            }
        }
    }
    return enemy
}

func (u *Unit) IsDead() bool {
    return u.Hp <= 0
}

func (u *Unit) HasTarget() bool {
    return u.Target != nil && !u.Target.IsDead()
}

func (u *Unit) Update() {
    if u.LifetimeCost > 0 {
        u.TakeDamage(u.LifetimeCost)
    }

    if u.IsAttacking() {
        u.HandleAttack()
    } else {
        if !u.HasTarget() || !u.CanAttack(u.Target) {
            u.Target = u.FindNearestEnemy()
        }
        if u.Target == nil {
            u.State = Idle
            if u.Range > 0 {
                log.Printf("no target found : %v", u.Name)
            }
        } else {
            if u.CanAttack(u.Target) {
                u.State = Attack
                u.StartAttack()
                log.Printf("attacking %v, Hp : %v", u.Target.Name, u.Target.Hp)
            } else {
                u.State = Move
                u.MoveTo(u.Target)
                log.Printf("moving to %v", u.Target.Name)
            }
        }
    }

    // TODO : apply repulsion force
}
