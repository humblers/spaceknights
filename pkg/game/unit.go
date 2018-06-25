package game

import "github.com/humblers/spaceknights/pkg/fixed"
import "github.com/humblers/spaceknights/pkg/physics"
import "github.com/humblers/spaceknights/pkg/nav"

type unit struct {
	world *physics.World
	_map  nav.Map
	body  *physics.Body
}

func (u *unit) init(w *physics.World, m nav.Map, posX, posY int) {
	u.world = w
	u._map = m
	u.body = w.AddCircle(
		fixed.FromInt(10),     // mass
		u.world.FromPixel(30), // radius
		fixed.Vector{u.world.FromPixel(posX), u.world.FromPixel(posY)},
	)
}

func (u *unit) update(step int, enemy *physics.Body) {
	corner := u._map.FindNextCornerInPath(
		u.body.Pos,
		enemy.Pos,
		u.body.Radius,
	)
	direction_normal := corner.Sub(u.body.Pos).Normalized()
	u.body.Vel = direction_normal.Mul(u.world.FromPixel(100)) // multiply by speed
}
