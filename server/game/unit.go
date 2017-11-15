package main

import (
    "fmt"
    "github.com/golang/glog"
    "encoding/json"
    "math"
)

type State string
const (
    Idle        State = "idle"
    Attack      State = "attack"
    Move        State = "move"
)

type Layer string
type Layers []Layer
const (
    Ground Layer = "Ground"
    Air Layer = "Air"
)

type Type string
type Types []Type
const (
    Troop Type = "Troop"
    Building Type = "Building"
    Base Type = "Base"
    Knight Type = "Knight"
    Bullet Type = "bullet"
)

type Size string
const (
    Small Size = "small"
    Medium Size = "medium"
    Large Size = "large"
    XLarge Size = "xlarge"
)

func (layers Layers) Contains(layer Layer) bool {
    for _, l := range layers {
        if l == layer {
            return true
        }
    }
    return false
}

func (types Types) Contains(_type Type) bool {
    for _, t := range types {
        if t == _type {
            return true
        }
    }
    return false
}

type Unit struct {
    // invariant
    Team         Team
    Type         Type    `json:"-"`
    Name         string
    Layer        Layer   `json:"-"`
    TargetLayers Layers  `json:"-"`
    TargetTypes  Types   `json:"-"`
    Hp           int
    InvMass      float64 `json:"-"`
    Speed        float64 `json:"-"`
    PreHitDelay  int     `json:"-"`
    PostHitDelay int     `json:"-"`
    Radius       float64 `json:"-"`
    Size         Size    `json:"-"`
    Sight        float64 `json:"-"`
    Range        float64 `json:"-"`
    Damage       int     `json:"-"`
    DamageRadius float64 `json:"-"`
    LifetimeCost int     `json:"-"`
    SpawnThing   string  `json:"-"`
    SpawnSpeed   int     `json:"-"`
    RepairDelay  int     `json:"-"`

    // variant
    Id           int
    Game         *Game   `json:"-"`
    State        State
    Position     Vector2
    Heading      Vector2
    Velocity     Vector2
    Target       *Unit   `json:"-"`
    HitFrame     int     `json:"-"`
    SpawnFrame   int     `json:"-"`
    SpawnStack   int     `json:"-"`
    RepairFrame  int     `json:"-"`

    // event
    AttackStarted bool
}

func (u *Unit) String() string {
    return fmt.Sprintf("%v(%v)", u.Name, u.Id)
}

func (u *Unit) MarshalJSON() ([]byte, error) {
    type Alias Unit
    var targetId int
    if u.HasTarget() {
        targetId = u.Target.Id
    }
    return json.Marshal(&struct{
        *Alias
        TargetId int `json:",omitempty"`
    }{
        Alias: (*Alias)(u),
        TargetId: targetId,
    })
}

func (u *Unit) IsCore() bool {
    if u.Name == "maincore" || u.Name == "subcore" {
        return true
    }
    return false
}

func (u *Unit) FlipY() {
    u.Position.Y = MapHeight - u.Position.Y
}

type Units []*Unit
func (s Units) Filter(f func(*Unit) bool) Units {
    var filtered Units
    for _, x := range s {
        if f(x) {
            filtered = append(filtered, x)
        }
    }
    return filtered
}

func (u *Unit) TakeDamage(d int) {
    if u.Hp <= 0 {
        return
    }
    //glog.Infof("take damage : %v, unit : %v", d, u)
    if u.Hp -= d; u.Hp <= 0 {
        u.Game.Units = u.Game.Units.Filter(func(x *Unit) bool { return x.Id != u.Id })
        switch u.Type {
        case Troop, Building:
            if !u.IsCore() {
                u.ScatterBullets()
            }
        case Knight:
            u.RepairFrame = u.Game.Frame + u.RepairDelay
        }
    }
}

func (u *Unit) CanTarget(other *Unit) bool {
    if u.Team == other.Team {
        return false
    }
    if !u.TargetTypes.Contains(other.Type) {
        return false
    }
    if !u.TargetLayers.Contains(other.Layer) {
        return false
    }
    return true
}

func (u *Unit) DistanceTo(other *Unit) float64 {
    return u.Position.Minus(other.Position).Length()
}

func (me *Unit) FuturePosition() Vector2 {
    return me.Position.Plus(me.Velocity)
}

func (A *Unit) CollisionInfo(B *Unit) (float64, Vector2) {
    overlap := 0.0
    normal := Vector2{0, 0}
    if A != B && A.Layer == B.Layer {
        normal = B.FuturePosition().Minus(A.FuturePosition())
        overlap = A.Radius + B.Radius - normal.Length()
    }
    return overlap, normal.Normalize()
}

func (me *Unit) ResolveCollision() {
    if me.Type == Knight || me.Type == Bullet {
        return
    }
    for _, other := range me.Game.Units {
        overlap, normal := me.CollisionInfo(other)
        if overlap > 0 {
            ratio := me.InvMass / (me.InvMass + other.InvMass)
            sum := me.Radius + other.Radius
            distance := sum - overlap
            offset := math.Sqrt(sum * sum - distance * distance)
            if normal.Dot(me.Velocity.Normalize()) > 0.9 {
                if normal.Cross(me.Velocity) > 0 {
                    me.Velocity = me.Velocity.Plus(Vector2{-normal.Y, normal.X}.Multiply(offset * ratio))
                    //glog.Infof("%v %v(%v) right turn %v(%v), velocity : %v", me.Game.Frame, me.Name, me.Id, other.Name, other.Id, me.Velocity)
                } else {
                    me.Velocity = me.Velocity.Plus(Vector2{normal.Y, -normal.X}.Multiply(offset * ratio))
                    //glog.Infof("%v %v(%v) left turn %v(%v), velocity : %v", me.Game.Frame, me.Name, me.Id, other.Name, other.Id, me.Velocity)
                }
            } else {
                me.Velocity = me.Velocity.Plus(normal.Multiply(-overlap * ratio))
                //glog.Infof("%v %v(%v) step back %v(%v), velocity : %v", me.Game.Frame, me.Name, me.Id, other.Name, other.Id, me.Velocity)
            }
        }
    }
    me.Velocity = me.Velocity.Truncate(me.Speed)
    /*
    if me.Velocity.Dot(me.LastVelocity) < 0.1 {   // opposite direction
        me.Velocity = me.Velocity.Divide(2)
    }
    */
}

func (u *Unit) Move() {
    u.Position = u.Position.Plus(u.Velocity)
    if math.IsNaN(u.Position.X) || math.IsNaN(u.Position.Y) {
        glog.Infof("%v pos: %v, vel: %v", u, u.Position)
    }
}

func (u *Unit) CanSee(other *Unit) bool {
    if u.DistanceTo(other) < u.Sight {
        return true
    }
    return false
}

func (u *Unit) WithinRange(other *Unit) bool {
    if u.DistanceTo(other) < u.Range + u.Radius + other.Radius {
        return true
    }
    return false
}

func (u *Unit) IsAttacking() bool {
    return u.HitFrame > 0 &&
            u.Game.Frame >= u.HitFrame - u.PreHitDelay &&
            u.Game.Frame <= u.HitFrame + u.PostHitDelay
}

func (u *Unit) HasAttack() bool {
    return u.Damage > 0
}

func (u *Unit) HandleAttack() {
    if u.Game.Frame == u.HitFrame {
        if u.WithinRange(u.Target) {
            u.Target.TakeDamage(u.Damage)
            if u.DamageRadius > 0 {
                for _, unit := range u.Game.Units {
                    if u.Target == unit {
                        continue
                    }
                    if u.CanTarget(unit) && u.DamageRadius >= u.Target.DistanceTo(unit) - unit.Radius {
                        unit.TakeDamage(u.Damage)
                    }
                }
            }
        }
    }
    if u.Type != Knight {
        u.Heading = u.Target.Position.Minus(u.Position).Normalize()
    }
}

func (u *Unit) StartAttack() {
    u.AttackStarted = true
    u.HitFrame = u.Game.Frame + u.PreHitDelay
    u.HandleAttack()
}

func (u *Unit) ClearEvents() {
    u.AttackStarted = false
}

func (u *Unit) FindNearestTarget(filter func(*Unit) bool) *Unit {
    var target *Unit
    var distance float64
    for _, unit := range u.Game.Units {
        if !u.CanTarget(unit) {
            continue
        }
        if filter(unit) {
            dist := u.DistanceTo(unit)
            if target == nil || dist < distance {
                target, distance = unit, dist
            }
        }
    }
    return target
}

func (u *Unit) IsDead() bool {
    return u.Hp <= 0
}

func (u *Unit) HasTarget() bool {
    return u.Target != nil && !u.Target.IsDead()
}

func (u *Unit) HandleSpawn() {
    if u.SpawnSpeed <= 0 {
        return
    }

    if u.SpawnFrame == 0 || u.SpawnFrame == u.Game.Frame {
        getSpawnPos := func(radius float64) Vector2 {
            pos := u.Position
            if u.Team == Home {
                pos.Y = MapHeight - pos.Y
            }
            front := Vector2{X: pos.X, Y: pos.Y + u.Radius + radius}
            if Top.Contains(front) || Bottom.Contains(front) || LeftHole.Contains(front) || RightHole.Contains(front) {
                return front
            }
            if pos.X < 200.0 || pos.X > (RightHole.L + RightHole.R) / 2 {
                pos.X -= u.Radius + radius
            } else {
                pos.X += u.Radius + radius
            }
            return pos
        }
        switch u.SpawnThing {
        case "barbarians":
            unit := NewBarbarian(0, u.Team, Vector2{0, 0}, Vector2{0, 0})
            unit.Position = getSpawnPos(unit.Radius)
            u.Game.AddUnit(NewBarbarian(0, u.Team, unit.Position, Vector2{0, 0}))
            u.Game.AddUnit(unit)
        case "speargoblin":
            unit := NewSpeargoblin(0, u.Team, Vector2{0, 0}, Vector2{0, 0})
            unit.Position = getSpawnPos(unit.Radius)
            u.Game.AddUnit(unit)
        case "skeleton":
            unit := NewSkeleton(0, u.Team, Vector2{0, 0}, Vector2{0, 0})
            unit.Position = getSpawnPos(unit.Radius)
            u.Game.AddUnit(unit)
        case "knightbullet":
            if  u.SpawnStack % 6 >= 4 {
                break
            }
            u.SpawnStack++;
            bullet := NewKnightBullet(u.Team, Vector2{u.Position.X, TileHeight * 1.5 + u.Radius})
            u.Game.AddUnit(bullet)
            bullet.Heading = Vector2{0, bullet.Speed}
            if bullet.Team == Home {
                bullet.Heading.Y *= -1
            }
        default:
            glog.Errorf("unknown spawn thing : %v", u.SpawnThing)
        }
        u.SpawnFrame = u.Game.Frame + u.SpawnSpeed
    }
}

func (u *Unit) ScatterBullets() {
    var bulletVectors []Vector2
    switch u.Size {
    case Medium:
        bulletVectors = []Vector2{ {0, 1} }
    case Large, XLarge:
        bulletVectors = []Vector2{ {-3, 5}, {0, 1}, Vector2{3, 5} }
    }
    for _, vector := range bulletVectors {
        bullet := NewScatteredBullet(u.Team, u.Position)
        u.Game.AddUnit(bullet)
        bullet.Heading = vector.Normalize().Multiply(bullet.Speed)
        if bullet.Team == Home {
            bullet.FlipY()
            bullet.Heading.Y *= -1
        }
    }
}

func (u *Unit) Update() {
    u.ClearEvents()
    switch u.Type {
    case Troop:
        u.Velocity = Vector2{0, 0}
        if u.IsAttacking() {
            u.HandleAttack()
        } else {
            if !u.HasTarget() || !u.WithinRange(u.Target) {
                var filter = func (other *Unit) bool {
                    return u.CanSee(other) || other.IsCore()
                }
                u.Target = u.FindNearestTarget(filter)
            }
            if u.Target == nil {    // when all cores are destroyed (last frame update)
                u.State = Idle
                glog.Warningf("no target found : %v", u.Name)
            } else {
                if u.WithinRange(u.Target){
                    u.State = Attack
                    u.StartAttack()
                    //glog.Infof("attacking %v, Hp : %v", u.Target.Name, u.Target.Hp)
                } else {
                    u.State = Move
					destination := u.Target.Position
					if u.Layer == Ground {
						path := u.FindPath(u.Target)
						destination = u.NextCornerInPath(path)
					}
                    u.Velocity = destination.Minus(u.Position).Truncate(u.Speed)
                    u.Heading = u.Velocity
                    //glog.Infof("%v moving to %v", u.Name, destination)
                }
            }
        }
    case Building:
        u.TakeDamage(u.LifetimeCost)
        if u.HasAttack() {
            if u.IsAttacking() {
                u.HandleAttack()
            } else {
                if !u.HasTarget() || !u.WithinRange(u.Target) {
                    var filter = func(other *Unit) bool {
                        return u.WithinRange(other)
                    }
                    u.Target = u.FindNearestTarget(filter)
                }
                if u.Target == nil {
                    u.State = Idle
                } else {
                    u.State = Attack
                    u.StartAttack()
                    //glog.Infof("attacking %v, Hp : %v", u.Target.Name, u.Target.Hp)
                }
            }
        }
        u.HandleSpawn()
    case Knight:
        if u.IsAttacking() {
            u.HandleAttack()
        } else {
            if !u.HasTarget() || !u.WithinRange(u.Target) {
                var filter = func(other *Unit) bool {
                    return u.WithinRange(other)
                }
                u.Target = u.FindNearestTarget(filter)
            }
            if u.Target != nil {
                u.StartAttack()
                //glog.Infof("attacking %v, Hp : %v", u.Target.Name, u.Target.Hp)
            }
        }
        u.HandleSpawn()
    case Bullet:
        u.Position = u.Position.Plus(u.Heading.Truncate(u.Speed))
        if u.IsOutOfScreen() {
            u.Game.Units = u.Game.Units.Filter(func(x *Unit) bool { return x.Id != u.Id })
        } else {
            players := u.Game.Home
            if u.Team == Home {
                players = u.Game.Visitor
            }
            for _, player := range players {
                knight := player.Knight
                if knight.Hp > 0 && u.WithinRange(knight) {
                    knight.TakeDamage(u.Damage)
                    u.Game.Units = u.Game.Units.Filter(func(x *Unit) bool { return x.Id != u.Id })
                    break
                }
            }
        }
    case Base:
        return
    }
}

func (u *Unit) IsOutOfScreen() bool {
    if u.Position.X < 0 - u.Radius{
        return true
    }
    if u.Position.X > MapWidth + u.Radius {
        return true
    }
    if u.Position.Y < MapHeight - ScreenHeight {
        return true
    }
    if u.Position.Y > ScreenHeight {
        return true
    }
    return false
}

func (u *Unit) Location() (area *Area) {
    switch {
    case Top.Contains(u.Position):
        area = Top
    case Bottom.Contains(u.Position):
        area = Bottom
    case LeftHole.Contains(u.Position):
        area = LeftHole
    case RightHole.Contains(u.Position):
        area = RightHole
    default:
        //glog.Infof("invalid unit position : %v", u.Position)
        area = nil
    }
    return
}

func (from *Unit) FindPath(to *Unit) (portals []*Portal) {
    src := from.Location()
    dst := to.Location()
    switch src {
    case Top:
        switch dst {
        case Top:
            portals = []*Portal{}
        case Bottom:
            if from.Position.X < MapWidth / 2 {
                portals = []*Portal{TopToLeftHole, LeftHoleToBottom}
            } else {
                portals = []*Portal{TopToRightHole, RightHoleToBottom}
            }
        case LeftHole:
            portals = []*Portal{TopToLeftHole}
        case RightHole:
            portals = []*Portal{TopToRightHole}
        }
    case Bottom:
        switch dst {
        case Top:
            if from.Position.X < MapWidth / 2 {
                portals = []*Portal{BottomToLeftHole, LeftHoleToTop}
            } else {
                portals = []*Portal{BottomToRightHole, RightHoleToTop}
            }
        case Bottom:
            portals = []*Portal{}
        case LeftHole:
            portals = []*Portal{BottomToLeftHole}
        case RightHole:
            portals = []*Portal{BottomToRightHole}
        }
    case LeftHole:
        switch dst {
        case Top:
            portals = []*Portal{LeftHoleToTop}
        case Bottom:
            portals = []*Portal{LeftHoleToBottom}
        case LeftHole:
            portals = []*Portal{}
        case RightHole:
            if from.Team == Home {
                portals = []*Portal{LeftHoleToTop, TopToRightHole}
            } else {
                portals = []*Portal{LeftHoleToBottom, BottomToRightHole}
            }
        }
    case RightHole:
        switch dst {
        case Top:
            portals = []*Portal{RightHoleToTop}
        case Bottom:
            portals = []*Portal{RightHoleToBottom}
        case LeftHole:
            if from.Team == Home {
                portals = []*Portal{RightHoleToTop, TopToLeftHole}
            } else {
                portals = []*Portal{RightHoleToBottom, BottomToLeftHole}
            }
        case RightHole:
            portals = []*Portal{}
        }
    }
    portals = append(portals, &Portal{to.Position, to.Position})
    return
}

// find the next corner using funnel filter
func (u *Unit) NextCornerInPath(path []*Portal) Vector2 {
    if len(path) <= 0 {
        panic("invalid path")
    }
    portalLeft := path[0].Left
    portalRight := path[0].Right
    left := portalLeft.Minus(u.Position)
    right := portalRight.Minus(u.Position)
    for _, portal := range path[1:] {
        newPortalLeft := portal.Left
        newPortalRight := portal.Right
        newLeft := newPortalLeft.Minus(u.Position)
        newRight := newPortalRight.Minus(u.Position)
        if left.Cross(newLeft) >= 0 {
            if right.Cross(newLeft) > 0 {
                return portalRight
            }
            portalLeft = newPortalLeft
            left = newLeft
        }
        if right.Cross(newRight) <= 0 {
            if left.Cross(newRight) < 0 {
                return portalLeft
            }
            portalRight = newPortalRight
            right = newRight
        }
    }
    return portalLeft
}
