package physics

import (
	"testing"

	"git.humbler.games/spaceknights/spaceknights/pkg/fixed"
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
		if got := sw.digest(); got != 2406999703 {
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
	pc := fixed.Vector{dw.FromPixel(500), dw.FromPixel(200)}
	dw.AddCircle(fixed.FromInt(10), dw.FromPixel(30), pc)
	hash_results := []uint32{
		1794281626,
		3075692742,
		2763671526,
		858217978,
		1654299394,
		856948478,
		2761132526,
		3071884242,
		1789203626,
		3208057974,
	}
	for _, h := range hash_results {
		dw.Step()
		if got := dw.digest(); got != h {
			t.Errorf("Hash(%v), got(%v), want(%v)", dw, got, h)
		}
	}
}
