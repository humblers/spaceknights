extends Node

const INITIAL_HASH = 5381
const MASK = 0xFFFFFFFF

static func to_uint32(v):
	assert(typeof(v) == TYPE_INT)
	return v & MASK

static func is_uint32(v):
	assert(typeof(v) == TYPE_INT)
	return v >> 32 == 0

# djb2 hash
# http://www.cse.yorku.ca/~oz/hash.html
static func hash_uint32(u, prev):
	assert(is_uint32(u))
	assert(is_uint32(prev))
	return to_uint32(((prev << 5) + prev) + u)

static func HashBool(b):
	assert(typeof(b) == TYPE_BOOL)
	var h = INITIAL_HASH
	return hash_uint32(1, h) if b else hash_uint32(0, h)

static func HashInt(i):
	assert(typeof(i) == TYPE_INT)
	var h = INITIAL_HASH
	var upper = to_uint32(i >> 32)
	var lower = to_uint32(i)
	h = hash_uint32(upper, h)
	h = hash_uint32(lower, h)
	return h

static func HashString(s):
	assert(typeof(s) == TYPE_STRING)
	var h = INITIAL_HASH
	for c in s.to_ascii():
		h = hash_uint32(c, h)
	return h

static func Combine(hashes):
	assert(typeof(hashes) == TYPE_ARRAY)
	var h = INITIAL_HASH
	for e in hashes:
		h = hash_uint32(e, h)
	return h
	
static func TestHashBool():
	assert(HashBool(true) == 0x2B5A6)
	assert(HashBool(false) == 0x2B5A5)

static func TestHashInt64():
	assert(HashInt(0) == 0x596A45)
	assert(HashInt(1234567890) == 0x49EF6D17)

static func TestHashString():
	assert(HashString("") == 0x1505)
	assert(HashString("SpaceKnights") == 0xEFC09889)

static func TestCombine():
	assert(Combine(0, 0, 0) == 0xB86B2E5)