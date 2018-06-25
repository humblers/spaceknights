package physics

import (
	"testing"

	"github.com/humblers/spaceknights/pkg/fixed"
)

func TestWorld_HashStatic(t *testing.T) {
	// static world
	sw := NewWorld(map[string]fixed.Scalar{
		"scale":     fixed.One.Div(fixed.FromInt(10)),
		"dt":        fixed.One.Div(fixed.FromInt(10)),
		"gravity_y": fixed.FromInt(100),
	})
	pos := fixed.Vector{sw.FromPixel(500), sw.FromPixel(1500)}
	sw.AddBox(0,
		sw.FromPixel(400),
		sw.FromPixel(20),
		pos)
	for i := 0; i < 10; i++ {
		sw.Step()
		if got := sw.Digest(); got != 2406999703 {
			t.Errorf("Hash(%v), got(%v), want(%v)", sw, got, 2406999703)
		}
	}
}

func TestWorld_HashDynamic(t *testing.T) {
	// add simple falling circle for dynamic world
	dw := NewWorld(map[string]fixed.Scalar{
		"scale":     fixed.One.Div(fixed.FromInt(10)),
		"dt":        fixed.One.Div(fixed.FromInt(10)),
		"gravity_y": fixed.FromInt(100),
	})
	pb := fixed.Vector{dw.FromPixel(500), dw.FromPixel(1500)}
	dw.AddBox(0, dw.FromPixel(400), dw.FromPixel(20), pb)
	pc := fixed.Vector{dw.FromPixel(500), dw.FromPixel(100)}
	dw.AddCircle(fixed.FromInt(10), dw.FromPixel(30), pc)
	hash_results := []uint32{
		370068950,
		1651480066,
		1339458850,
		3728972598,
		230086718,
		3727703098,
		1336919850,
		1647671566,
		364990950,
		1783845298,
		1609267314,
		4136224294,
		774781646,
		114873962,
		2156501242,
		2604696190,
		2212255295,
		1843789993,
		1636990395,
		4131725761,
	}
	for i, h := range hash_results {
		dw.Step()
		for _, b := range dw.bodies {
			x, y := b.Pos.X, b.Pos.Y
			if x < 0 || x > dw.FromPixel(1000) || y < 0 || y > dw.FromPixel(1700) {
				dw.RemoveBody(b)
			}
		}
		if got := dw.Digest(); got != h {
			t.Errorf("Hash(%v), got(%v), want(%v), index(%v)", dw, got, h, i)
		}
	}
}
