package main

import "log"

type Unit struct {
    Id int `json:"-"`
    Game *Game `json:"-"`
    Team Team
    Type string `json:"-"`
    Name string
    Position Vector2
    Layer Layer
    Hp int
    Speed float64
    HitSpeed int `json:"-"` // # of frames
    Radius float64 `json:"-"`
    Sight float64 `json:"-"`
    Range float64 `json:"-"`
    Damage int `json:"-"`
    Velocity Vector2 `json:"-"`
    Target *Unit `json:"-"`
    LastHit int `json:"-"`
}

func (u *Unit) FlipY() {
    u.Position.Y = MapHeight - u.Position.Y
}

func (u *Unit) TakeDamage(d int) {
    u.Hp -= d
    if u.Hp <= 0 {
        delete(u.Game.Units, u.Id)
    }
}

func (u *Unit) Attackable() bool {
    switch u.Type {
    case "knight":
        return false
    case "mothership":
        if u.Name == "base" {
            return false
        }
    }
    return true
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

func (u *Unit) Attack(other *Unit) {
    if u.Game.Frame > u.LastHit + u.HitSpeed {
        other.TakeDamage(u.Damage)
        u.LastHit = u.Game.Frame
    }
}

func (u *Unit) FindNearestEnemy() *Unit {
    var enemy *Unit
    for _, unit := range u.Game.Units {
        if unit.Team == u.Team || !unit.Attackable() {
            continue
        }
        if unit.Type == "mothership" || u.CanSee(unit) {
            if enemy == nil || u.DistanceTo(enemy) > u.DistanceTo(unit) {
                enemy = unit
            }
        }
    }
    if enemy == nil {
        panic("no target found")
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
    if u.Type != "barbarian" {
        return
    }
    if !u.HasTarget() || !u.CanAttack(u.Target) {
        u.Target = u.FindNearestEnemy()
    }
    log.Printf("target found : %v", u.Target.Type)

    if u.CanAttack(u.Target) {
        u.Attack(u.Target)
        log.Printf("attacking %v, Hp : %v", u.Target.Type, u.Target.Hp)
    } else {
        u.MoveTo(u.Target)
        log.Printf("moving to %v", u.Target.Type)
    }
}
