package main

type Unit struct {
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
    if u.Hp < 0 {
        u.Hp = 0
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
    u.Position.Plus(direction.Multiply(u.Speed))
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

func (u *Unit) Attack(other *Unit, g *Game) {
    if g.Frame > u.LastHit + u.HitSpeed {
        other.TakeDamage(u.Damage)
        u.LastHit = g.Frame
    }
}

func (u *Unit) Update(game *Game) {
    if u.Type != "barbarian" {
        return
    }

    if u.Target == nil || !u.CanAttack(u.Target) {
        u.Target = game.FindNearestEnemy(u)
    }

    if u.CanAttack(u.Target) {
        u.Attack(u.Target, game)
    } else {
        u.MoveTo(u.Target)
    }
}
