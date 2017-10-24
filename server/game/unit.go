package main

import (
    "github.com/golang/glog"
    "encoding/json"
    "math"
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
    //desired := position.Minus(u.Position).Normalize().Multiply(u.Speed)
    //return desired.Minus(u.Velocity).Divide(10)
	desired := position.Minus(u.Position).Normalize().Multiply(1)
	//glog.Infof("i = %v, seek4s =  %.3f", u.Name, desired.Minus(u.Velocity).Length())
	//glog.Infof("i = %v, seek4s =  %.3f", u.Name, desired.Length())
	//return desired.Minus(u.Velocity)
	return desired
	
	
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
				//sum = sum.Plus(direction.Multiply(intersection/u.Mass+1)) // middle of them
				sum = sum.Plus(direction.Multiply(intersection)) //best
 				//sum = sum.Plus(direction.Multiply(intersection/u.Mass)) //too slow reaction
				
				//u.Velocity = Vector2{0, 0}
				u.Velocity = u.Velocity.Divide(1.5)
				
				//glog.Infof("I = %v, now Vel =  %.3f,  add S4s = %.3f", u.Name, u.Velocity.Length(), sum)
				
				sideDot := sum.Dot(u.Side())
				if sideDot > 0 {					
					steer = 1
				} else {
					steer = -1
				}
				
				if (u.Speed == unit.Speed && u.Team != unit.Team) {
					unitSteer := 0.0
					unitSideDot := sum.Multiply(-1).Dot(unit.Side())
					if unitSideDot > 0 {
						unitSteer = 1
					} else {
						unitSteer = -1
					}
					if u.Side().Multiply(steer).Dot(unit.Side().Multiply(unitSteer)) > 0 {
						glog.Infof("Coner Case!!!! %v team %v Unit ID = %v , other ID = %v",u.Team, u.Name, u.Id, unit.Id)
						glog.Infof("ID %v ori_steer =  %v",u.Id, steer)
						if u.Id > unit.Id {
							steer = steer * -1
						}
						glog.Infof("ID %v result_steer =  %v",u.Id, steer)
					}
				}
				
				sum = sum.Plus(u.Side().Multiply(steer))
			
			//glog.Infof("%v try to separate from %v, %v, %v", u.Name, unit.Name, intersection, direction)
			//glog.Infof("%v team %v steer =  %v",u.Team, u.Name, steer)
				
            }
        }
    }
    return sum
}

func (u *Unit) Side() Vector2 {
    return Vector2{u.Heading.Y, -u.Heading.X}
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

const minTimeToCollision = 50.0

func (u *Unit) Avoid() Vector2 {
    steer := 0.0
    if u.Velocity.Length() == 0 {
        return Vector2{0, 0}
    }
    minTime := minTimeToCollision
    minDist := math.MaxFloat64
    var threat *Unit
    var threatPositionAtNearestApproach Vector2
    for _, other := range u.Game.Units {
        if other == u || other == u.Target || other.Layer != u.Layer || other.Team != u.Team {
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

    if threat != nil {
        if threat.Speed < u.Speed || (threat.Speed == u.Speed && threat.Id < u.Id) {
            offset := threatPositionAtNearestApproach.Minus(u.Position)
            sideDot := offset.Dot(u.Side())
            if sideDot > 0 {
                //steer = -1
				steer = -1
            } else {
                steer = 1
            }
            //glog.Infof("%v try to avoid %v, %v, %v, %v", u.Name, threat.Name, steer, minTime, minDist)
        }
    }

	minDist = minDist + 1
    return u.Side().Multiply(steer)
}


func (u *Unit) AddForce(force Vector2) {
    u.Acceleration = u.Acceleration.Plus(force.Divide(u.Mass))
}

func (u *Unit) AddAcceleration(acc Vector2) {
    u.Acceleration = u.Acceleration.Plus(acc)
}

func (u *Unit) Move() {
    //const smoothRate = 0.1
	//var smoothRate = 1.0
	//if u.State == Move {
    //    smoothRate = 1.0
    //}
    //old_vel := u.Velocity
    new_vel := u.Velocity.Plus(u.Acceleration).Truncate(u.Speed)
    //u.Velocity = old_vel.Plus(new_vel.Minus(old_vel).Multiply(smoothRate)).Truncate(u.Speed)
	u.Velocity = new_vel
	
	if u.Velocity.Length() != 0 {
		//glog.Infof(" I = %v, Pos = %.3f, Vel = %.3f", u.Name, u.Position, u.Velocity.Length())
	}
	
    u.Position = u.Position.Plus(u.Velocity)
    u.Acceleration = Vector2{0, 0}
    if u.State == Move {
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
                    if u.CanTarget(unit) && u.DamageRadius >= u.Target.DistanceTo(unit) {
                        unit.TakeDamage(u.Damage)
                    }
                }
            }
        }
    }
    u.Velocity = Vector2{0, 0}
    u.Heading = u.Target.Position.Minus(u.Position).Normalize()
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
                    //u.State = Move
					u.State = Collision
					//glog.Infof("i  = %v, separate =  %v, separate var = %v", u.Name, separate.Length() , separate)
                    if separate.Length() == 0 {
                        u.State = Move
						/*
						avoid := u.Avoid()
                        u.AddAcceleration(avoid)
                        if avoid.Length() == 0 {
                            position := u.Target.Position
                            if u.Layer == Ground {
                                path := u.FindPath(u.Target)
                                position = u.NextCornerInPath(path)
                            }
                            u.AddAcceleration(u.Seek(position))
                            glog.Infof("i = %v, moving to %v", u.Name, position)
                        }
						*/
                    }
					
					
					avoid := u.Avoid()
					avoid.Multiply(1)
					//u.AddAcceleration(avoid)
					position := u.Target.Position
					if u.Layer == Ground {
						path := u.FindPath(u.Target)
						position = u.NextCornerInPath(path)
					}
					u.AddAcceleration(u.Seek(position))
					
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
