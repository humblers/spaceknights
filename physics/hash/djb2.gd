extends Node

const INITIAL_HASH = 5381

# calling hash() for cast result value to uint32
static func HashDJB2(input, prev = INITIAL_HASH):
	return hash(((prev << 5) + prev) + hash(input))

## set of test functions for hash result
#func _ready():
#	var cases_int = [
#		# if integer value is greater than uint32_max.
#		# it can be replaced by uint32_max value. because of godot's hash() func behavior
#		[(1 << 63) - 1, 177572],
#		[(1 << 32) - 1, 177572],
#
#		[(1 << 31) - 1, 2147661220],
#	]
#	for c in cases_int:
#		assert(HashDJB2(c[0]) == c[1])
#
#	var cases_str = [
#		["a", 355243],
#		["spaceknights", 2910229102],
#	]
#	for c in cases_str:
#		assert(HashDJB2(c[0]) == c[1])
#
#	var cases_arr = [
#		[[(1<<63) - 1, (1<<48) - 1, (1<<32) - 1, (1<<16) - 1], 134358278],
#		[[(1<<32) - 1, (1<<32) - 1, (1<<32) - 1, (1<<16) - 1], 134358278],
#	]
#	for c in cases_arr:
#		assert(HashDJB2(c[0]) == c[1])
#
#	var cases_fixed = [
#		[scalar.One, 243109],
#		[scalar.FromInt((1<<15) - 1),  2147595685],
#		# equal to fixed Vector (1, 1)
#		[[scalar.One, scalar.One], 195782794]
#	]
#	for c in cases_fixed:
#		assert(HashDJB2(c[0]) == c[1])
#
#	var body = load("res://physics/body.gd")
#	var b = body.new(
#		1,
#		scalar.FromInt(100),
#		scalar.Div(scalar.One, scalar.Two),
#		scalar.One,
#		scalar.One
#	)
#	var cases_physics = [
#		[b, 2771927977],
#	]
#	for c in cases_physics:
#		assert(c[0].digest() == c[1])