package main

import (
    "github.com/golang/glog"
    "encoding/json"
)

type State string
const (
    Idle        State = "idle"
    StartAttack State = "startattack"
    Attacking   State = "attack"
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
)

const MaxSeparationForce = 20

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
    Mass         float64 `json:"-"`
    Speed        float64 `json:"-"`
    PreHitDelay  int     `json:"-"`
    PostHitDelay int     `json:"-"`
    Radius       float64 `json:"-"`
    Sight        float64 `json:"-"`
    Range        float64 `json:"-"`
    Damage       int     `json:"-"`
    DamageRadius float64 `json:"-"`
    LifetimeCost int     `json:"-"`
    SpawnThing   string  `json:"-"`
    SpawnSpeed   int     `json:"-"`

    // variant
    Id           int     `json:"-"`
    Game         *Game   `json:"-"`
    State        State
    Position     Vector2
    Heading      Vector2
    Velocity     Vector2
    Acceleration Vector2 `json:"-"`
    Target       *Unit   `json:"-"`
    HitFrame     int     `json:"-"`
    SpawnFrame   int     `json:"-"`
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

func (u *Unit) TakeDamage(d int) {
    if u.Hp -= d; u.Hp <= 0 {
        delete(u.Game.Units, u.Id)
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

func (u *Unit) Seek(position Vector2) Vector2 {
    desired := position.Minus(u.Position).Normalize().Multiply(u.Speed)
    u.Heading = desired
    return desired.Minus(u.Velocity)
}

func (u *Unit) Separate() Vector2 {
    sum := Vector2{0, 0}
    for _, unit := range u.Game.Units {
        if u.Layer != unit.Layer {
            continue
        }
        d := u.DistanceTo(unit)
        if d > 0 && d < u.Radius + unit.Radius {
            intersection := u.Radius + unit.Radius - d
            direction := u.Position.Minus(unit.Position).Normalize()
            sum = sum.Plus(direction.Multiply(unit.Mass).Divide(intersection))
        }
    }
    return sum.Truncate(MaxSeparationForce)
}

func (u *Unit) Forward() Vector2 {
    return u.Velocity.Normalize()
}

func (u *Unit) Side() Vector2 {
    forward := u.Forward()
    return Vector2{forward.Y, -forward.X}
}

func (u *Unit) PredictNearestApproachTime(other *Unit) float64 {
    relVelocity := other.Velocity.Minus(u.Velocity)
    relSpeed := relVelocity.Length()
    if relSpeed == 0 {
        return 0
    }
    relTangent := relVelocity.Divide(relSpeed)
    relPosition := u.Position.Minus(other.Position)
    projection := relTangent.Dot(relPosition)
    return projection / relSpeed
}

func (u *Unit) ComputeNearestApproachPositions(other *Unit, time float64) (Vector2, Vector2) {
    myPos := u.Position.Plus(u.Velocity.Multiply(time))
    otherPos := other.Position.Plus(other.Velocity.Multiply(time))
    return myPos, otherPos
}

const minTimeToCollision = 20.0
func (u *Unit) Avoid() Vector2 {
    steer := 0.0
    if u.Velocity.Length() == 0 {
        return Vector2{0, 0}
    }
    minTime := minTimeToCollision
    minDist := 500.0
    var threat *Unit
    var threatPositionAtNearestApproach Vector2
    for _, other := range u.Game.Units {
        if other == u || other == u.Target {
            continue
        }
        collisionDangerThreshold := u.Radius + other.Radius
        time := u.PredictNearestApproachTime(other)
        if time >= 0 && time < minTime {
            myPos, otherPos := u.ComputeNearestApproachPositions(other, time)
            distance := myPos.Minus(otherPos).Length()
            if distance < collisionDangerThreshold {
                minTime = time
                minDist = distance
                threat = other
                threatPositionAtNearestApproach = otherPos
            }
        }
    }

    if threat != nil && threat.Velocity.Length() <= u.Velocity.Length() {
        parallelness := u.Forward().Dot(threat.Forward())
        const angle = 0.707
        if parallelness < -angle {
            offset := threatPositionAtNearestApproach.Minus(u.Position)
            sideDot := offset.Dot(u.Side())
            if sideDot > 0 {
                steer = -1
            } else {
                steer = 1
            }
            glog.Infof("anti-parallel %v try to avoid %v, %v, %v, %v", u.Name, threat.Name, steer, minTime, minDist)
        } else {
            if parallelness > angle {
                offset := threat.Position.Minus(u.Position)
                sideDot := offset.Dot(u.Side())
                if sideDot > 0 {
                    steer = -1
                } else {
                    steer = 1
                }
                glog.Infof("parallel %v try to avoid %v, %v, %v, %v", u.Name, threat.Name, steer, minTime, minDist)
            } else {
                sideDot := u.Side().Dot(threat.Velocity)
                if sideDot > 0 {
                    steer = -1
                } else {
                    steer = 1
                }
                glog.Infof("perpendicular %v try to avoid %v, %v, %v, %v", u.Name, threat.Name, steer, minTime, minDist)
            }
        }
    }

    return u.Side().Multiply(steer)
}

func (u *Unit) AddForce(force Vector2) {
    u.Acceleration = u.Acceleration.Plus(force)   // f = ma
}

func (u *Unit) Move() {
    u.Velocity = u.Velocity.Plus(u.Acceleration)
    u.Position = u.Position.Plus(u.Velocity)
    u.Acceleration = Vector2{0, 0}
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
    u.Heading = u.Target.Position.Minus(u.Position)
    if u.Game.Frame == u.HitFrame {
        if u.WithinRange(u.Target) {
            u.Target.TakeDamage(u.Damage)
            if u.DamageRadius > 0 {
                for _, unit := range u.Game.Units {
                    if u.Target == unit {
                        continue
                    }
                    if u.CanTarget(unit) && u.DamageRadius >= u.Target.DistanceTo(unit) {
                        unit.TakeDamage(u.Damage)
                    }
                }
            }
        }
    }
    u.Velocity = Vector2{0, 0}
}

func (u *Unit) StartAttack() {
    u.HitFrame = u.Game.Frame + u.PreHitDelay
    u.HandleAttack()
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
        getSpawnPos := func(building *Unit, spawnRadius float64) Vector2 {
            pos := u.Position
            if building.Team == Home {
                pos.Y = MapHeight - pos.Y
            }
            front := Vector2{X: pos.X, Y: pos.Y + u.Radius + spawnRadius}
            if Top.Contains(front) || Bottom.Contains(front) || LeftHole.Contains(front) || RightHole.Contains(front) {
                return front
            }
            if pos.X < 200.0 || pos.X > (RightHole.L + RightHole.R) / 2 {
                pos.X -= u.Radius + spawnRadius
            } else {
                pos.X += u.Radius + spawnRadius
            }
            return pos
        }
        switch u.SpawnThing {
        case "barbarians":
            pos := getSpawnPos(u, 11)
            u.Game.AddUnit(NewBarbarian(0, u.Team, pos, Vector2{X:0, Y:0}))
            u.Game.AddUnit(NewBarbarian(0, u.Team, pos, Vector2{X:0, Y:0}))
        case "speargoblin":
            pos := getSpawnPos(u, 9)
            u.Game.AddUnit(NewSpeargoblin(0, u.Team, pos, Vector2{X:0, Y:0}))
        default:
            glog.Errorf("unknown spawn thing : %v", u.SpawnThing)
        }
        u.SpawnFrame = u.Game.Frame + u.SpawnSpeed
    }
}

func (u *Unit) Update() {
    switch u.Type {
    case Troop:
        if u.IsAttacking() {
            u.State = Attacking
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
                    u.State = StartAttack
                    u.StartAttack()
                    //glog.Infof("attacking %v, Hp : %v", u.Target.Name, u.Target.Hp)
                } else {
                    u.State = Move
                    position := u.Target.Position
                    if u.Layer == Ground {
                        path := u.FindPath(u.Target)
                        position = u.NextCornerInPath(path)
                    }
                    //glog.Infof("moving to %v", position)
                    u.AddForce(u.Seek(position))
                    u.AddForce(u.Avoid().Multiply(2))
                }
            }
        }
    case Building:
        u.TakeDamage(u.LifetimeCost)
        if u.HasAttack() {
            if u.IsAttacking() {
                u.State = Attacking
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
                    u.State = StartAttack
                    u.StartAttack()
                    glog.Infof("attacking %v, Hp : %v", u.Target.Name, u.Target.Hp)
                }
            }
        }
        u.HandleSpawn()
    case Base, Knight:
        return
    }
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
        glog.Infof("invalid unit position : %v", u.Position)
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
                return []*Portal{TopToLeftHole, LeftHoleToBottom}
            } else {
                return []*Portal{TopToRightHole, RightHoleToBottom}
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
                return []*Portal{BottomToLeftHole, LeftHoleToTop}
            } else {
                return []*Portal{BottomToRightHole, RightHoleToTop}
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
                return []*Portal{LeftHoleToTop, TopToRightHole}
            } else {
                return []*Portal{LeftHoleToBottom, BottomToRightHole}
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
                return []*Portal{RightHoleToTop, TopToLeftHole}
            } else {
                return []*Portal{RightHoleToBottom, BottomToLeftHole}
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
