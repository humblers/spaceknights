package main

const (
	MothershipMainHeight    = 40
	MothershipSubHeight     = 60
	MothershipBaseHeight    = 70
	MothershipBoosterHeight = 10

	MaincoreScore = 3
	SubcoreScore  = 1
)

func NewMothership(t Team) []*Unit {
	var mothership []*Unit
	main := &Unit{
		Team:    t,
		Type:    Building,
		Name:    "maincore",
		Layer:   Ground,
		Hp:      4008,
		InvMass: 0,
		Radius:  20,
		Position: Vector2{
			X: MapWidth / 2,
			Y: MothershipBaseHeight - MothershipBoosterHeight + MothershipMainHeight/2,
		},
	}
	left := &Unit{
		Team:    t,
		Type:    Building,
		Name:    "subcore",
		Layer:   Ground,
		Hp:      2534,
		InvMass: 0,
		Radius:  30,
		Position: Vector2{
			X: 70,
			Y: MothershipBaseHeight - MothershipBoosterHeight + MothershipSubHeight/2,
		},
	}
	right := &Unit{
		Team:    t,
		Type:    Building,
		Name:    "subcore",
		Layer:   Ground,
		Hp:      2534,
		InvMass: 0,
		Radius:  30,
		Position: Vector2{
			X: 330,
			Y: MothershipBaseHeight - MothershipBoosterHeight + MothershipSubHeight/2,
		},
	}
	base := &Unit{
		Team:    t,
		Type:    Base,
		Name:    "base",
		Layer:   Ground,
		InvMass: 0,
		Position: Vector2{
			X: MapWidth / 2,
			Y: MothershipBaseHeight / 2,
		},
	}
	mothership = append(mothership, right, main, left, base)

	// flip
	for _, u := range mothership {
		if u.Team == Home {
			u.Position.X = MapWidth - u.Position.X
			u.Position.Y = MapHeight - u.Position.Y
		}
	}
	return mothership
}
