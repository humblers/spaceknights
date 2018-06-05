package djb2

import (
	"fmt"
	"reflect"

	"git.humbler.games/spaceknights/spaceknights/pkg/fixed"
)

const INITIAL_HASH uint32 = 5381

func hashBytes(in []byte) uint32 {
	hash := INITIAL_HASH

	for _, c := range in {
		hash = ((hash << 5) + hash) + uint32(c) /* hash * 33 + c */
	}
	return hash
}

func hashOne(in uint32, opt ...uint32) uint32 {
	prev := INITIAL_HASH
	if len(opt) > 0 {
		prev = opt[0]
	}
	return ((prev << 5) + prev) + in
}

func Hash(in interface{}, opt ...uint32) uint32 {
	// Fast path for basic types and slices(without reflect)
	var hash_in uint32
	switch v := in.(type) {
	case *int32:
		hash_in = uint32(*v)
	case int32:
		hash_in = uint32(v)
	case []int32:
		hash_in = hashOne(0)
		for i := 0; i < len(v); i++ {
			hash_in = hashOne(uint32(v[i]), hash_in)
		}
	case *uint32:
		hash_in = *v
	case uint32:
		hash_in = v
	case []uint32:
		hash_in = hashOne(0)
		for i := 0; i < len(v); i++ {
			hash_in = hashOne(v[i], hash_in)
		}
	case *int64:
		hash_in = uint32(*v)
	case int64:
		hash_in = uint32(v)
	case []int64:
		hash_in = hashOne(0)
		for i := 0; i < len(v); i++ {
			hash_in = hashOne(uint32(v[i]), hash_in)
		}
	case *fixed.Scalar:
		hash_in = uint32(*v)
	case fixed.Scalar:
		hash_in = uint32(v)
	case []fixed.Scalar:
		hash_in = hashOne(0)
		for i := 0; i < len(v); i++ {
			hash_in = hashOne(uint32(v[i]), hash_in)
		}
	// work same as type:[]uint32,len:2
	case *fixed.Vector:
		hash_in = hashOne(0)
		hash_in = hashOne(uint32((*v).X), hash_in)
		hash_in = hashOne(uint32((*v).Y), hash_in)
	case fixed.Vector:
		hash_in = hashOne(0)
		hash_in = hashOne(uint32(v.X), hash_in)
		hash_in = hashOne(uint32(v.Y), hash_in)
	case *string:
		hash_in = hashBytes([]byte(*v))
	case string:
		hash_in = hashBytes([]byte(v))
	case *[]byte:
		hash_in = hashBytes(*v)
	case []byte:
		hash_in = hashBytes(v)
	default:
		panic(fmt.Errorf("Unknown input type(%v), value(%v)", reflect.TypeOf(in), v))
	}

	return hashOne(hash_in, opt...)
}
