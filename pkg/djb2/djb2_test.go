package djb2_test

import "testing"
import "github.com/humblers/spaceknights/pkg/djb2"

func TestHashBool(t *testing.T) {
	cases := []struct {
		in   bool
		want uint32
	}{
		{in: true, want: 0x2B5A6},
		{in: false, want: 0x2B5A5},
	}
	for _, c := range cases {
		if got := djb2.HashBool(c.in); got != c.want {
			t.Errorf("HashBool(%v), got(%X), want (%X)", c.in, got, c.want)
		}
	}
}

func TestHashInt(t *testing.T) {
	cases := []struct {
		in   int
		want uint32
	}{
		{in: 0, want: 0x596A45},
		{in: 1234567890, want: 0x49EF6D17},
	}
	for _, c := range cases {
		if got := djb2.HashInt(c.in); got != c.want {
			t.Errorf("HashInt(%v), got(%X), want (%X)", c.in, got, c.want)
		}
	}
}

func TestHashString(t *testing.T) {
	cases := []struct {
		in   string
		want uint32
	}{
		{in: "", want: 0x1505},
		{in: "SpaceKnights", want: 0xEFC09889},
	}
	for _, c := range cases {
		if got := djb2.HashString(c.in); got != c.want {
			t.Errorf("HashString(%v), got(%X), want (%X)", c.in, got, c.want)
		}
	}
}

func TestCombine(t *testing.T) {
	cases := []struct {
		h1, h2, h3, want uint32
	}{
		{h1: 0, h2: 0, h3: 0, want: 0xB86B2E5},
	}
	for _, c := range cases {
		if got := djb2.Combine(c.h1, c.h2, c.h3); got != c.want {
			t.Errorf("Combine(%v, %v, %v), got(%X), want (%X)", c.h1, c.h2, c.h3, got, c.want)
		}
	}
}
