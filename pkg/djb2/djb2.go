package djb2

const INITIAL_HASH uint32 = 5381

// djb2 hash
// http://www.cse.yorku.ca/~oz/hash.html
func hash_uint32(u, prev uint32) uint32 {
	return ((prev << 5) + prev) + u
}

func HashBool(b bool) uint32 {
	h := INITIAL_HASH
	if b {
		return hash_uint32(1, h)
	} else {
		return hash_uint32(0, h)
	}
}

func HashInt(i int) uint32 {
	h := INITIAL_HASH
	upper := uint32(i >> 32)
	lower := uint32(i)
	h = hash_uint32(upper, h)
	h = hash_uint32(lower, h)
	return h
}

func HashString(s string) uint32 {
	h := INITIAL_HASH
	for _, b := range []byte(s) {
		h = hash_uint32(uint32(b), h)
	}
	return h
}

func Combine(hashes ...uint32) uint32 {
	h := INITIAL_HASH
	for _, e := range hashes {
		h = hash_uint32(e, h)
	}
	return h
}
