package hash

import (
	"fmt"
	"reflect"

	"git.humbler.games/spaceknights/spaceknights/pkg/fixed"
)

const INITIAL_HASH uint32 = 5381

func hash_djb2(in []byte) uint32 {
	hash := INITIAL_HASH

	for _, c := range in {
		hash = ((hash << 5) + hash) + uint32(c) /* hash * 33 + c */
	}
	return hash
}

func hash_djb2_one_32(in uint32, opt ...uint32) uint32 {
	prev := INITIAL_HASH
	if len(opt) > 0 {
		prev = opt[0]
	}
	return ((prev << 5) + prev) + in
}

// https://gist.github.com/badboy/6267743#64-bit-to-32-bit-hash-functions
func hash_64_32_shift(in uint64) uint32 {
	in = (^in) + (in << 18) // in = (in << 18) - in - 1;
	in = in ^ (in >> 31)
	in = in * 21 // in = (in + (in << 2)) + (in << 4);
	in = in ^ (in >> 11)
	in = in + (in << 6)
	in = in ^ (in >> 22)
	return uint32(in)
}

func HashDJB2(in interface{}, opt ...uint32) uint32 {
	// Fast path for basic types and slices(without reflect)
	var hash_in uint32
	switch v := in.(type) {
	case *int32:
		hash_in = uint32(*v)
	case int32:
		hash_in = uint32(v)
	case []int32:
		hash_in = hash_djb2_one_32(0)
		for i := 0; i < len(v); i++ {
			hash_in = hash_djb2_one_32(uint32(v[i]), hash_in)
		}
	case *uint32:
		hash_in = *v
	case uint32:
		hash_in = v
	case []uint32:
		hash_in = hash_djb2_one_32(0)
		for i := 0; i < len(v); i++ {
			hash_in = hash_djb2_one_32(v[i], hash_in)
		}
	case *int64:
		hash_in = uint32(*v & (1<<32 - 1))
	case int64:
		hash_in = uint32(v & (1<<32 - 1))
	case []int64:
		hash_in = hash_djb2_one_32(0)
		for i := 0; i < len(v); i++ {
			hash_in = hash_djb2_one_32(uint32(v[i]&(1<<32-1)), hash_in)
		}
	case *fixed.Scalar:
		hash_in = uint32(*v & (1<<32 - 1))
	case fixed.Scalar:
		hash_in = uint32(v & (1<<32 - 1))
	case []fixed.Scalar:
		hash_in = hash_djb2_one_32(0)
		for i := 0; i < len(v); i++ {
			hash_in = hash_djb2_one_32(uint32(v[i]&(1<<32-1)), hash_in)
		}
	case *fixed.Vector:
		hash_in = hash_djb2_one_32(uint32((*v).X&(1<<32-1)), uint32((*v).Y&(1<<32-1)))
	case fixed.Vector:
		hash_in = hash_djb2_one_32(uint32(v.X&(1<<32-1)), uint32(v.Y&(1<<32-1)))
	case *string:
		hash_in = hash_djb2([]byte(*v))
	case string:
		hash_in = hash_djb2([]byte(v))
	case *[]byte:
		hash_in = hash_djb2(*v)
	case []byte:
		hash_in = hash_djb2(v)
	default:
		panic(fmt.Errorf("Unknown input type(%v), value(%v)", reflect.TypeOf(in), v))
	}

	return hash_djb2_one_32(hash_in, opt...)
}
