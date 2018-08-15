package game

import "fmt"

type tileRect struct {
	t, b, l, r int
}

func (t *tileRect) String() string {
	return fmt.Sprintf("t,b,l,r: %v,%v,%v,%v", t.t, t.b, t.l, t.r)
}

func (a *tileRect) intersects(b *tileRect) bool {
	if a.t > b.b {
		return false
	}
	if a.b < b.t {
		return false
	}
	if a.l > b.r {
		return false
	}
	if a.r < b.l {
		return false
	}
	return true
}

type TileOccupier interface {
	GetRect(x, y, w, h int) *tileRect
	Occupy(tr *tileRect) error
	Occupied() *tileRect
	Release()
}

type tileOccupier struct {
	Game
	occupied *tileRect
}

func newTileOccupier(g Game) *tileOccupier {
	return &tileOccupier{
		Game: g,
	}
}

func (t *tileOccupier) GetRect(x, y, w, h int) *tileRect {
	if w%2 == 0 || h%2 == 0 {
		panic("not implemented even number of tile occupy")
	}
	w, h = w/2, h/2
	return &tileRect{y - h, y + h, x - w, x + w}
}

func (t *tileOccupier) Occupy(tr *tileRect) error {
	if t.occupied != nil {
		return fmt.Errorf("occupier already occupy tile: %v", t.occupied)
	}

	gOccupied := t.Game.OccupiedTiles()
	for occupied, _ := range gOccupied {
		if occupied.intersects(tr) {
			return fmt.Errorf("tile intersects, occupied: %v, new: %v", occupied, tr)
		}
	}
	t.occupied = tr
	gOccupied[t.occupied] = true
	return nil
}

func (t *tileOccupier) Occupied() *tileRect {
	return t.occupied
}

func (t *tileOccupier) Release() {
	delete(t.Game.OccupiedTiles(), t.occupied)
	t.occupied = nil
}
