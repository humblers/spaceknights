package main

type Unit struct {
    Team Team
    Name string
    Position Vector2
    Layer Layer
    Hp int
    Radius float64 `json:"-"`
    Sight float64 `json:"-"`
    Range float64 `json:"-"`
    Damage int `json:"-"`
    Velocity Vector2 `json:"-"`
    Target *Unit `json:"-"`
}

func (u *Unit) TakeDamage(d int) {
    u.Hp -= d
    if u.Hp < 0 {
        u.Hp = 0
    }
}

func (u *Unit) CanSee(other *Unit) bool {
    if u.Position.Minus(other.Position).Length() < u.Sight {
        return true
    }
    return false
}

func (u *Unit) CanAttack(other *Unit) bool {
    if u.Position.Minus(other.Position).Length() < u.Range {
        return true
    }
    return false
}

func (u *Unit) Attack(other *Unit) {
    other.TakeDamage(u.Damage)
}

func (u *Unit) Update(game *Game) {
    if u.Name != "barbarian" {
        return
    }
    // move
    if u.Target != nil {
        if u.CanSee(u.Target) {
            u.Attack(u.Target)
        } else {
            u.Target = nil
        }
    } else {
    }
    // scan enemy within sight
    var nearest *Unit
    for _, unit := range game.Units {
        if u.CanSee(unit) {
            nearest = unit
        }
    }
    // if found and within range, attack
    if nearest != nil && u.CanAttack(nearest) {
    } else {
        u.Attack(nearest)
    }
    // else set direction to enemy
    // add steering forces (seperation)
}
