package game

import "github.com/humblers/spaceknights/pkg/fixed"

type Team string

type Layer string
type Layers []Layer

type Type string
type Types []Type

type Unit interface {
	Id() int
	Team() Team
	Radius() fixed.Scalar
	Position() fixed.Vector
	Type() Type
	Layer() Layer
	IsDead() bool
	TakeDamage(amount int)
	Update()
}

const (
	Home    Team = "home"
	Visitor Team = "visitor"

	Ground Layer = "ground"
	Air    Layer = "air"

	Troop    Type = "troop"
	Building Type = "building"
	Knight   Type = "knight"
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
