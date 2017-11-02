package main

import (
    "fmt"
    "github.com/golang/glog"
    "encoding/json"
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
    RepairDelay  int     `json:"-"`

    // variant
    Id           int
    Game         *Game   `json:"-"`
    State        State
    Position     Vector2
    Heading      Vector2
    Velocity     Vector2
    Acceleration Vector2 `json:"-"`
    Target       *Unit   `json:"-"`
    HitFrame     int     `json:"-"`
    SpawnFrame   int     `json:"-"`
    RepairFrame  int     `json:"-"`

    // event
    AttackStarted bool
    Colliding bool `json:"-"`
}

func (u *Unit) String() string {
    return fmt.Sprintf("%v", u.Name)
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
func (s Units) Filter(f func(*Unit) bool) {
    filtered := s[:0]
    for _, x := range s {
        if f(x) {
            filtered = append(filtered, x)
        }
    }
    s = filtered
}

func (u *Unit) TakeDamage(d int) {
    if u.Hp <= 0 {
        return
    }
    if u.Hp -= d; u.Hp <= 0 {
        u.Game.Units.Filter(func(x *Unit) bool { return x.Id != u.Id })
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

func (u *Unit) Seek(position Vector2) Vector2 {
	desired := position.Minus(u.Position).Normalize().Multiply(1)
	return desired
}

/*
const MaxSight = 50.0
func (me *Unit) Avoid() Vector2 {
    for _, obstacle := range me.Game.Units {
        if obstacle == me || me.Layer != obstacle.Layer {
            continue
        }
        center := obstacle.Position.ToLocalCoordinate(me)
        top := center.Y + obstacle.Radius
        bottom := center.Y - obstacle.Radius
    }
    return Vector2{0, 0}
}
*/

func (me *Unit) ResolveCollision() {
    mostHeavyObstacleMass := 0.0
    for i := 0; i < 1; i++ {
        for _, obstacle := range me.Game.Units {
            if obstacle == me || me.Layer != obstacle.Layer || obstacle.Mass < me.Mass || obstacle.Mass < mostHeavyObstacleMass {
                continue
            }
            distance := me.Position.Minus(obstacle.Position).Length()
            intersection := obstacle.Radius + me.Radius - distance
            if intersection > 0  {
               // if i > 3 {
               //     glog.Infof("%v having difficulty to resolve collision %v", me.Name, obstacle.Name)
               // }
                offset := me.Position.Minus(obstacle.Position).Multiply(intersection/distance)
                me.Position = me.Position.Plus(offset)
                mostHeavyObstacleMass = obstacle.Mass
            }
        }
    }
}

func (u *Unit) Separate() Vector2 {
    sum := Vector2{0, 0}
	steer := 0.0
    for _, unit := range u.Game.Units {
        if u.Layer != unit.Layer {
            continue
        }
        d := u.DistanceTo(unit)
        if d > 0 && d < u.Radius + unit.Radius {
            if u.Speed > unit.Speed || (u.Speed == unit.Speed && (u.Id > unit.Id || unit.Team != u.Team )) {
				intersection := u.Radius + unit.Radius - d
				direction := u.Position.Minus(unit.Position).Normalize()
				sum = sum.Plus(direction.Multiply(intersection))
				u.Velocity = u.Velocity.Divide(1.5)
				sideDot := sum.Dot(u.Side())
				if sideDot > 0 {
					steer = 1
				} else {
					steer = -1
				}
				if u.Speed == unit.Speed && u.Team != unit.Team {
					unitSteer := 0.0
					unitSideDot := sum.Multiply(-1).Dot(unit.Side())
					if unitSideDot > 0 {
						unitSteer = 1
					} else {
						unitSteer = -1
					}
					if u.Side().Multiply(steer).Dot(unit.Side().Multiply(unitSteer)) > 0 {
						//glog.Infof("Coner Case!!!! %v team %v Unit ID = %v , other ID = %v",u.Team, u.Name, u.Id, unit.Id)						
						if u.Id > unit.Id {
							steer = steer * -1
						}
					}
				}
				if intersection > 10 || u.Team != unit.Team {
					sum = sum.Plus(u.Side().Multiply(steer))
				} else {
					sum = u.Side().Multiply(steer)
				}
			glog.Infof("%v try to separate from %v, %.3f ", u.Name, unit.Name, intersection)
			//glog.Infof("%v team %v steer =  %v",u.Team, u.Name, steer)
            }
        }
    }
    return sum
}

func (u *Unit) Side() Vector2 {
    return Vector2{u.Heading.Y, -u.Heading.X}
}

func (u *Unit) AddAcceleration(acc Vector2) {
    u.Acceleration = u.Acceleration.Plus(acc)
}

func (u *Unit) Move() {
    if u.Type != Troop {
        return
    }
    u.Velocity = u.Velocity.Plus(u.Acceleration).Truncate(u.Speed)
    u.Position = u.Position.Plus(u.Velocity)
    u.Acceleration = Vector2{0, 0}
    if !u.Colliding {
        u.Heading = u.Velocity.Normalize()
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
    //u.Velocity = Vector2{0, 0}
    u.Heading = u.Target.Position.Minus(u.Position).Normalize()
}

func (u *Unit) StartAttack() {
    u.AttackStarted = true
    u.HitFrame = u.Game.Frame + u.PreHitDelay
    u.HandleAttack()
}

func (u *Unit) ClearEvents() {
    u.AttackStarted = false
    u.Colliding = false
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
            pos := getSpawnPos(unit.Radius)
            u.Game.AddUnit(unit)
            u.Game.AddUnit(NewBarbarian(0, u.Team, pos, Vector2{0, 0}))
        case "speargoblin":
            unit := NewSpeargoblin(0, u.Team, Vector2{0, 0}, Vector2{0, 0})
            unit.Position = getSpawnPos(unit.Radius)
            u.Game.AddUnit(unit)
        case "knightbullet":
            bullet := NewKnightBullet(u.Team, Vector2{u.Position.X, TileHeight * 1.5 + u.Radius})
            bullet.Velocity = Vector2{0, bullet.Speed}
            if bullet.Team == Home {
                bullet.Velocity.Y *= -1
            }
            u.Game.AddUnit(bullet)
        default:
            glog.Errorf("unknown spawn thing : %v", u.SpawnThing)
        }
        u.SpawnFrame = u.Game.Frame + u.SpawnSpeed
    }
}

var ScatterDirections = []Vector2{Vector2{-3, 5}.Normalize(), Vector2{0, 1}, Vector2{3, 5}.Normalize()}
func (u *Unit) ScatterBullets() {
    for _, direction := range ScatterDirections {
        bullet := NewScatteredBullet(u.Team, u.Position)
        bullet.Velocity = direction.Multiply(bullet.Speed)
        if bullet.Team == Home {
            bullet.FlipY()
            bullet.Velocity.Y *= -1
        }
        u.Game.AddUnit(bullet)
    }
}

func (u *Unit) Update() {
    u.ClearEvents()
    switch u.Type {
    case Troop:
        /*
        separate := u.Separate()
        if separate.Length() > 0 {
            u.Colliding = true
            u.AddAcceleration(separate)
        }
        */
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
					//u.AddAcceleration(u.Seek(position))
                    u.Heading = destination.Minus(u.Position)
                    u.Position = u.Position.Plus(u.Heading.Truncate(u.Speed))
                }
            }
        }
        u.ResolveCollision()
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
                    glog.Infof("attacking %v, Hp : %v", u.Target.Name, u.Target.Hp)
                }
            }
        }
        u.HandleSpawn()
    case Knight:
        u.HandleSpawn()
    case Bullet:
        u.Move()
        if u.IsOutOfScreen() {
            delete(u.Game.Units, u.Id)
        } else {
            players := u.Game.Home
            if u.Team == Home {
                players = u.Game.Visitor
            }
            for _, player := range players {
                knight := player.Knight
                if knight.Hp > 0 && u.WithinRange(knight) {
                    knight.TakeDamage(u.Damage)
                    delete(u.Game.Units, u.Id)
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
