package main

import (
    "log"
    "reflect"
    "time"
)

type Unit struct {
    Id int `json:"-"`
    Game *Game `json:"-"`
    Team Team
    Type string `json:"-"`
    Name string
    Position Vector2
    Layer Layer
    TargetLayers []Layer `json:"-""`
    Hp int
    Speed float64 `json:"-"`
    HitSpeed int `json:"-"` // # of frames
    Radius float64 `json:"-"`
    Sight float64 `json:"-"`
    Range float64 `json:"-"`
    Damage int `json:"-"`
    Lifetime int `json:"-"` // # of secs
    LifetimeCost int `json:"-"`
    Velocity Vector2 `json:"-"`
    Target *Unit `json:"-"`
    LastHit int `json:"-"`
}

func (u *Unit) SetLifetimeCost() *Unit{
    if u.Lifetime <= 0 {
        return u
    }
    interval := int(time.Duration(u.Lifetime) * time.Second / LifetimeCostInterval)
    u.LifetimeCost = u.Hp / interval
    return u
}

func (u *Unit) FlipY() {
    u.Position.Y = MapHeight - u.Position.Y
}

func (u *Unit) TakeDamage(d int) {
    if u.Hp -= d; u.Hp <= 0 {
        delete(u.Game.Units, u.Id)
    }
}

func (u *Unit) TakeLifetimeCost() {
    if u.LifetimeCost > 0 && u.Game.Frame % int(LifetimeCostInterval / FrameInterval) == 0 {
        u.TakeDamage(u.LifetimeCost)
    }
}

func (u *Unit) Attackable(target *Unit) bool {
    if u.Team == target.Team {
        return false
    }
    if !Contains(u.TargetLayers, target.Layer) {
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
    implementedUnits := [...]string{"barbarian", "cannon", "archer"}
    if !Contains(implementedUnits, u.Type) {
        return
    }
    u.TakeLifetimeCost()
    if !u.HasTarget() || !u.CanAttack(u.Target) {
        u.Target = u.FindNearestEnemy()
    }
    if u.Target == nil {
        log.Printf("no target found : %v", u.Target.Type)
        return
    }

    if u.CanAttack(u.Target) {
        u.Attack(u.Target)
        log.Printf("attacking %v, Hp : %v", u.Target.Type, u.Target.Hp)
    } else {
        u.MoveTo(u.Target)
        log.Printf("moving to %v", u.Target.Type)
    }
}

func Contains(source interface{}, element interface{}) bool {
    sourceRef := reflect.ValueOf(source)
    if sourceRef.Kind() == reflect.Slice || sourceRef.Kind() == reflect.Array {
        for i := 0; i < sourceRef.Len(); i++ {
            if sourceRef.Index(i).Interface() == element {
                return true
            }
        }
    }
    // ToDo : add another interface cases
    return false
}