package physics

import (
	"testing"

	"git.humbler.games/spaceknights/spaceknights/pkg/fixed"
)

func TestBody_Hash(t *testing.T) {
	b := newBody(1, fixed.FromInt(100), fixed.One.Div(fixed.Two), fixed.Vector{fixed.One, fixed.One})

	cases := []struct {
		body *body
		want uint32
	}{
		{body: b, want: 866701722},
	}
	for _, c := range cases {
		if got := c.body.digest(); got != c.want {
			t.Errorf("Hash Body(%v), got(%v), want(%v)", c.body, got, c.want)
		}
	}
}
