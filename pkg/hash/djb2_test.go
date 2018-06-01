package hash_test

import (
	"testing"

	. "git.humbler.games/spaceknights/spaceknights/pkg/hash"
)

func TestHash_Chain(t *testing.T) {
	cases := []struct {
		in   interface{}
		prev uint32
		want uint32
	}{
		{in: uint32(5381), prev: 0, want: 5381},
		{in: []int64{1<<63 - 1, 1<<48 - 1, 1<<32 - 1}, prev: 0, want: 2086472482},
	}
	for _, c := range cases {
		if got := HashDJB2(c.in, c.prev); got != c.want {
			t.Errorf("Hash (%v), got(%v), want (%v)", c.in, got, c.want)
		}
	}
}

func TestHash_Int(t *testing.T) {
	var int64_max int64 = 1<<63 - 1
	var uint32_max uint32 = 1<<32 - 1
	var int32_val int32 = 1<<31 - 1
	var uint32_val = uint32(int32_val)
	cases := []struct {
		in   interface{}
		want uint32
	}{
		{in: int64_max, want: 177572},
		{in: &int64_max, want: 177572},
		{in: uint32_max, want: 177572},
		{in: &uint32_max, want: 177572},
		{in: int32_val, want: 2147661220},
		{in: &int32_val, want: 2147661220},
		{in: uint32_val, want: 2147661220},
		{in: &uint32_val, want: 2147661220},
	}
	for _, c := range cases {
		if got := HashDJB2(c.in); got != c.want {
			t.Errorf("Hash (%v), got(%v), want (%v)", c.in, got, c.want)
		}
	}
}

func TestHash_String(t *testing.T) {
	var sample_str string = "spaceknights"
	var sample_bytes = []byte(sample_str)
	const HASH = 2910229102

	cases := []struct {
		in   interface{}
		want uint32
	}{
		{in: "a", want: 355243},
		{in: sample_str, want: HASH},
		{in: &sample_str, want: HASH},
		{in: sample_bytes, want: HASH},
		{in: &sample_bytes, want: HASH},
	}
	for _, c := range cases {
		if got := HashDJB2(c.in); got != c.want {
			t.Errorf("Hash (%v), got(%v), want (%v)", c.in, got, c.want)
		}
	}
}

func TestHash_Slice_Int(t *testing.T) {
	cases := []struct {
		in   interface{}
		want uint32
	}{
		{in: []int64{1<<63 - 1, 1<<48 - 1, 1<<32 - 1, 1<<16 - 1}, want: 134358278},
		{in: []int64{1<<32 - 1, 1<<32 - 1, 1<<32 - 1, 1<<16 - 1}, want: 134358278},

		{in: []int64{1<<31 - 1, 1<<16 - 1}, want: 2340926147},
		{in: []int32{1<<31 - 1, 1<<16 - 1}, want: 2340926147},
		{in: []uint32{1<<31 - 1, 1<<16 - 1}, want: 2340926147},
	}
	for _, c := range cases {
		if got := HashDJB2(c.in); got != c.want {
			t.Errorf("Hash (%v), got(%v), want (%v)", c.in, got, c.want)
		}
	}
}
