extends Node

var config = ConfigFile.new()

var id

var team
var knights = {}

const CARD_WAIT_FRAME = 10 - 1 # server send snapshot after 1 frame
const UNIT_LAUNCH_TIME = 0.1 * (CARD_WAIT_FRAME - 1)

const SERVER_UPDATES_PER_SECOND = 10
const PLAY_TIME = 3 * 60 * SERVER_UPDATES_PER_SECOND
const DOUBLE_AFTER = 2 * 60 * SERVER_UPDATES_PER_SECOND
const OVER_TIME = 3 * 60 * SERVER_UPDATES_PER_SECOND

const MOTHERSHIP_BASE_HEIGHT = 60
const SCREEN_HEIGHT = 640
const MAP = {
	"width" : 320,
	"height" : 544,
}

const LAYERS = {
	"Mothership": 0,
	"MothershipOver": 1,
	"GroundUnder": 2,
	"Ground": 3,
	"GroundOver": 4,
	"Air": 5,
	"Projectile": 6,
	"UI": 100,
}

const UNITS = {
	"archer" : {
		"layer" : "Ground",
		"hp" : 254,
		"prehitdelay" : 1,
		"radius" : 9,
		"sight" : 100,
		"range" : 70,
		"projectile" : "archer",
		"size" : "small",
	},
	"footman" : {
		"layer" : "Ground",
		"hp" : 636,
		"radius" : 11,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"barrack" : {
		"layer" : "Ground",
		"hp" : 1936,
		"radius" : 20,
		"lifetimecost" : 3,
		"size" : "large",
	},
	"blaster" : {
		"layer" : "Ground",
		"hp" : 311,
		"prehitdelay" : 10,
		"radius" : 11,
		"sight" : 100,
		"range" : 80,
		"projectile" : "bomber_missile",
		"size" : "medium",
	},
	"blastturret" : {
		"layer" : "Ground",
		"hp" : 1672,
		"prehitdelay": 10,
		"radius" : 20,
		"sight" : 120,
		"range" : 120,
		"projectile" : "bombtower_missile",
		"lifetimecost" : 4,
		"size" : "large",
	},
	"cannon" : {
		"layer" : "Ground",
		"hp" : 742,
		"prehitdelay": 2,
		"radius" : 20,
		"sight" : 120,
		"range" : 110,
		"projectile" : "cannon",
		"lifetimecost" : 2,
		"size" : "large",
	},
	"jouster" : {
		"layer" : "Ground",
		"hp" : 1243,
		"radius" : 13,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"frost" : {
		"layer" : "Air",
		"hp" : 2534 * 2 / 3,
		"prehitdelay" : 3,
		"radius" : 10,
		"sight" : 200,
		"range" : 200,
		"projectile" : "freezer",
		"size" : "large",
	},
	"drillram" : {
		"layer" : "Ground",
		"hp" : 1408,
		"radius" : 14,
		"sight" : 120,
		"range" : 15,
		"size" : "medium",
	},
	"giant" : {
		"layer" : "Ground",
		"hp" : 3344,
		"radius" : 28,
		"sight" : 150,
		"range" : 15,
		"size" : "xlarge",
	},
	"sentryshelter" : {
		"layer" : "Ground",
		"hp" : 1293,
		"radius" : 28,
		"lifetimecost" : 2,
		"size" : "large",
	},
	"knightbullet" : {
		"layer" : "Air",
		"radius" : 12,
	},
	"scatteredbullet" : {
		"layer" : "Air",
		"radius" : 7,
	},
	"legion" : {
		"layer" : "Air",
		"hp" : 2534 * 2 / 3,
		"prehitdelay" : 3,
		"radius" : 10,
		"sight" : 200,
		"range" : 200,
		"projectile" : "legion",
		"size" : "large",
	},
	"astra" : {
		"layer" : "Air",
		"hp" : 4008 * 2 / 3,
		"prehitdelay" : 10,
		"radius" : 10,
		"sight" : 200,
		"range" : 200,
		"projectile" : "knight_missile",
		"size" : "large",
	},
	"gargoyleking" : {
		"layer" : "Air",
		"hp" : 695,
		"radius" : 20,
		"sight" : 100,
		"range" : 20,
		"size" : "large",
	},
	"gargoyle" : {
		"layer" : "Air",
		"hp" : 190,
		"radius" : 10,
		"sight" : 100,
		"range" : 20,
		"size" : "small",
	},
	"berserker" : {
		"layer" : "Ground",
		"hp" : 1056,
		"radius" : 12,
		"sight" : 100,
		"range" : 15,
		"size" : "small",
	},
	"maincore" : {
		"layer" : "Mothership",
		"hp" : 4008,
		"radius" : 20,
		"size" : "xlarge",
	},
	"subcore" : {
		"layer" : "Mothership",
		"hp" : 2534,
		"radius" : 30,
		"size" : "xlarge",
	},
	"base" : {
		"layer" : "Mothership",
	},
	"starfire" : {
		"layer" : "Ground",
		"hp" : 598,
		"prehitdelay": 3,
		"radius" : 11,
		"sight" : 100,
		"range" : 85,
		"projectile" : "starfire",
		"size" : "large",
	},
	"ogre" : {
		"layer" : "Ground",
		"hp" : 3458,
		"radius" : 13,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"champion" : {
		"layer" : "Ground",
		"hp" : 1536,
		"radius" : 14,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"pixie" : {
		"layer" : "Ground",
		"hp" : 67,
		"radius" : 6,
		"sight" : 100,
		"range" : 5,
		"size" : "small",
	},
	"sentry" : {
		"layer" : "Ground",
		"hp" : 110,
		"prehitdelay" : 4,
		"radius" : 9,
		"sight" : 100,
		"range" : 70,
		"projectile" : "sentry",
		"size" : "small",
	},
	"pixiegeode" : {
		"layer" : "Ground",
		"hp" : 422,
		"radius" : 17,
		"lifetimecost" : 1,
		"size" : "large",
	},
	"enforcer" : {
		"layer" : "Ground",
		"hp" : 1548,
		"radius": 12,
		"sight" : 100,
		"range" : 20,
		"size" : "medium",
	},
	"felhound" : {
		"layer" : "Ground",
		"hp" : 80,
		"radius" : 11,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"judge" : {
		"layer" : "Air",
		"hp" : 2534 * 2 / 3,
		"prehitdelay" : 3,
		"radius" : 10,
		"sight" : 200,
		"range" : 200,
		"projectile" : "knight_missile",
		"size" : "large",
	},
	"lancer" : {
		"layer" : "Air",
		"hp" : 2534 * 2 / 3,
		"prehitdelay" : 3,
		"radius" : 10,
		"sight" : 200,
		"range" : 200,
		"projectile" : "knight_missile",
		"size" : "large",
	},
	"nagmash" : {
		"layer" : "Air",
		"hp" : 2534 * 2 / 3,
		"prehitdelay" : 3,
		"radius" : 10,
		"sight" : 200,
		"range" : 200,
		"projectile" : "knight_missile",
		"size" : "large",
	},
	"panzerkunstler" : {
		"layer" : "Ground",
		"hp" : 2056,
		"radius" : 12,
		"sight" : 150,
		"range" : 15,
		"size" : "medium",
	},
	"psabu" : {
		"layer" : "Ground",
		"hp" : 3458,
		"radius" : 13,
		"sight" : 150,
		"range" : 15,
		"size" : "medium",
	},
	"shadowvision" : {
		"layer" : "Air",
		"hp" : 800,
		"prehitdelay" : 19,
		"radius" : 20,
		"sight" : 100,
		"range" : 80,
		"projectile" : "bomber_missile",
		"size" : "large",
	},
	"trainee" : {
		"layer" : "Ground",
		"hp" : 120,
		"radius" : 11,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"wasp" : {
		"layer" : "Air",
		"hp" : 1000,
		"prehitdelay" : 7,
		"radius" : 20,
		"sight" : 100,
		"range" : 20,
		"size" : "large",
	},
}

const CARDS = {
	"archers" : {
		"type" : "troop",
		"cost" : 3000,
		"unitname" : "archer",
		"unitoffsets" : [ Vector2(1, 0), Vector2(-1, 0) ],
	},
	"barrack" : {
		"type" : "building",
		"cost" : 7000,
	},
	"footman" : {
		"type" : "troop",
		"cost" : 5000,
		"unitname" : "footman",
		"unitoffsets" : [ Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1) ],
	},
	"blaster" : {
		"type" : "troop",
		"cost" : 3000,
	},
	"blastturret" : {
		"type" : "building",
		"cost" : 5000,
	},
	"cannon" : {
		"type" : "building",
		"cost" : 3000,
	},
	"jouster" : {
		"type" : "troop",
		"cost" : 4000,
	},
	"giant" : {
		"type" : "troop",
		"cost" : 5000,
	},
	"sentryshelter" : {
		"type" : "building",
		"cost" : 5000,
	},
	"drillram" : {
		"type" : "troop",
		"cost" : 4000,
	},
	"gargoyleking" : {
		"type" : "troop",
		"cost" : 3000,
	},
	"gargoylehorde" : {
		"type" : "troop",
		"cost" : 5000,
		"unitname" : "gargoyle",
		"unitoffsets" : [ Vector2(0, -2), Vector2(1, -1), Vector2(-1, -1),
				Vector2(0, 2), Vector2(1, 1), Vector2(-1, 1) ],
	},
	"gargoyles" : {
		"type" : "troop",
		"cost" : 3000,
		"unitname" : "gargoyle",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"berserker" : {
		"type" : "troop",
		"cost" : 4000,
	},
	"starfire" : {
		"type" : "troop",
		"cost" : 4000,
	},
	"ogre" : {
		"type" : "troop",
		"cost" : 7000,
	},
	"champion" : {
		"type" : "troop",
		"cost" : 5000,
	},
	"pixie" : {
		"type" : "troop",
		"cost" : 1000,
		"unitname" : "pixie",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"sentry" : {
		"type" : "troop",
		"cost" : 2000,
		"unitname" : "sentry",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"threestarfire" : {
		"type" : "troop",
		"cost" : 9000,
		"unitname" : "starfire",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"pixiegeode" : {
		"type" : "building",
		"cost" : 3000,
	},
	"enforcer" : {
		"type" : "troop",
		"cost" : 4000,
	},

	"fireball" : {
		"type" : "spell",
		"cost" : 11000,
		"range" : 200,
		"radius" : 50.0,
		"shape" : "circular",
	},
	"laser" : {
		"type" : "spell",
		"cost" : 11000,
		"range" : 150,
		"radius" : 20.0,
		"shape" : "linear",
	},
	"freeze" : {
		"type" : "spell",
		"cost" : 11000,
		"range" : 200,
		"radius" : 60.0,
		"shape" : "circular",
	},
	"felhound" : {
		"type" : "troop",
		"cost" : 2000,
		"unitname" : "felhound",
		"unitoffsets" : [ Vector2(0, 0), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1) ],
	},
	"panzerkunstler" : {
		"type" : "troop",
		"cost" : 5000,
	},
	"psabu" : {
		"type" : "troop",
		"cost" : 7000,
	},
	"shadowvision" : {
		"type" : "troop",
		"cost" : 4000,
	},
	"trainee" : {
		"type" : "troop",
		"cost" : 2000,
		"unitname" : "trainee",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"wasp" : {
		"type" : "troop",
		"cost" : 5000,
	},
}

func _ready():
	randomize()
	load_config()

func load_config():
	var err = config.load("user://settings.cfg")
	if err != OK:
		print("can't find settings.cfg. try create new one")
		save_config()

func save_config():
	assert(config.save("user://settings.cfg") == OK)

static func dict_get(dict, key, not_found_val=null):
	if dict.has(key):
		return dict[key]
	return not_found_val

static func shuffle_array(arr):
	for i in range(arr.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var i_val = arr[i]
		var j_val = arr[j]
		arr[i] = j_val
		arr[j] = i_val
	return arr

static func clone(data):
	var to
	if typeof(data) == TYPE_DICTIONARY:
		to = {}
		for key in data:
			to[key] = clone(data[key])
	elif typeof(data) == TYPE_ARRAY:
		to = []
		for value in data:
			to.append(clone(value))
	else:
		to = data
	return to

static func draw_circle_arc(radius, color, canvasitem, center = Vector2(0, 0), angle_from = 0, angle_to = 360):
	var nb_points = 32
	var points_arc = Vector2Array()
	for i in range(nb_points+1):
		var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
		var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
		points_arc.push_back( point )
	for indexPoint in range(nb_points):
		canvasitem.draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color)

const CARD_THRESHOLD_TOP = 288
const LOCATION_UI = 0
const LOCATION_BASE = 1
const LOCATION_BLUE = 2
const LOCATION_RED = 3

func get_location(pos):
	if pos.y > global.MAP.height + 32:
		return LOCATION_UI
	if pos.y < CARD_THRESHOLD_TOP:
		return LOCATION_RED
	return LOCATION_BLUE

func is_spell_card(name):
	if CARDS[name].type == "spell":
		return true
	return false

func is_unit_card(name):
	if CARDS[name].type in ["troop", "building"]:
		return true
	return false

func get_structures_of_unit(card):
	var dict = dict_get(CARDS, card.Name, {})
	var name = card.Name
	var offsets = [ Vector2(0, 0) ]
	if dict.has("unitname"):
		name = dict.unitname
	if dict.has("unitoffsets"):
		offsets = dict.unitoffsets
	var units = []
	for offset in offsets:
		if card.Team == "Home":
			offset.y = offset.y * -1
		var unit = {
			"Name" : name,
			"Team" : card.Team,
			"Position" : {
				"X" : card.Position.X + offset.x * global.dict_get(global.UNITS[name], "radius", 0),
				"Y" : card.Position.Y + offset.y * global.dict_get(global.UNITS[name], "radius", 0),
			},
		}
		units.append(unit)
	return units

func get_scale(cardname, org_size):
	var card = CARDS[cardname]
	if card["shape"] == "circular":
		return Vector2(
				card["radius"] * 2 / org_size.x,
				card["radius"] * 2 / org_size.y
		)
	if card["shape"] == "linear":
		return Vector2(
				card["radius"] * 2 / org_size.x,
				card["range"] * 2 / org_size.y
		)