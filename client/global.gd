extends Node

var config = ConfigFile.new()

var id

var team
var knights = {}

const CARD_WAIT_FRAME = 10 - 1 # server send snapshot after 1 frame
const UNIT_LAUNCH_TIME = 0.1 * (CARD_WAIT_FRAME - 1)
const SERVER_UPDATES_PER_SECOND = 10

const MOTHERSHIP_BASE_HEIGHT = 60
const SCREEN_HEIGHT = 640
const MAP = {
	"width" : 400,
	"height" : 560,
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
		"hp" : 100,
		"prehitdelay" : 4,
		"radius" : 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
		"size" : "small",
	},
	"barbarian" : {
		"layer" : "Ground",
		"hp" : 300,
		"radius" : 11,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"barbarianhut" : {
		"layer" : "Ground",
		"hp" : 900,
		"radius" : 20,
		"lifetimecost" : 2,
		"size" : "large",
	},
	"bomber" : {
		"layer" : "Ground",
		"hp" : 150,
		"prehitdelay" : 10,
		"radius" : 11,
		"sight" : 100,
		"range" : 90,
		"projectile" : "bomber_missile",
		"size" : "medium",
	},
	"bombtower" : {
		"layer" : "Ground",
		"hp" : 900,
		"prehitdelay": 10,
		"radius" : 20,
		"sight" : 120,
		"range" : 120,
		"projectile" : "bombtower_missile",
		"lifetimecost" : 1,
		"size" : "large",
	},
	"cannon" : {
		"layer" : "Ground",
		"hp" : 450,
		"prehitdelay": 5,
		"radius" : 20,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
		"lifetimecost" : 1,
		"size" : "large",
	},
	"darkprince" : {
		"layer" : "Ground",
		"hp" : 920,
		"radius" : 13,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"giant" : {
		"layer" : "Ground",
		"hp" : 1800,
		"radius" : 28,
		"sight" : 200,
		"range" : 15,
		"size" : "xlarge",
	},
	"goblinhut" : {
		"layer" : "Ground",
		"hp" : 600,
		"radius" : 28,
		"lifetimecost" : 1,
		"size" : "large",
	},
	"knightbullet" : {
		"layer" : "Air",
	},
	"scatteredbullet" : {
		"layer" : "Air",
	},
	"shuriken" : {
		"layer" : "Air",
		"hp" : 100,
		"prehitdelay" : 10,
		"radius" : 20,
		"sight" : 140,
		"range" : 140,
		"projectile" : "knight_missile",
	},
	"space_z" : {
		"layer" : "Air",
		"hp" : 100,
		"prehitdelay" : 10,
		"radius" : 31,
		"sight" : 140,
		"range" : 140,
		"projectile" : "knight_missile",
	},
	"megaminion" : {
		"layer" : "Air",
		"hp" : 300,
		"radius" : 20,
		"sight" : 80,
		"range" : 50,
		"size" : "large",
	},
	"minion" : {
		"layer" : "Air",
		"hp" : 70,
		"radius" : 10,
		"sight" : 80,
		"range" : 20,
		"size" : "small",
	},
	"minipekka" : {
		"layer" : "Ground",
		"hp" : 600,
		"radius" : 12,
		"sight" : 100,
		"range" : 15,
		"size" : "small",
	},
	"maincore" : {
		"layer" : "Mothership",
		"hp" : 1200,
		"radius" : 20,
		"size" : "xlarge",
	},
	"subcore" : {
		"layer" : "Mothership",
		"hp" : 700,
		"radius" : 30,
		"size" : "xlarge",
	},
	"base" : {
		"layer" : "Mothership",
	},
	"musketeer" : {
		"layer" : "Ground",
		"hp" : 200,
		"prehitdelay": 3,
		"radius" : 11,
		"sight" : 120,
		"range" : 120,
		"projectile" : "bullet",
		"size" : "large",
	},
	"pekka" : {
		"layer" : "Ground",
		"hp" : 1800,
		"radius" : 13,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"prince" : {
		"layer" : "Ground",
		"hp" : 1100,
		"radius" : 14,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"skeleton" : {
		"layer" : "Ground",
		"hp" : 30,
		"radius" : 6,
		"sight" : 100,
		"range" : 5,
		"size" : "small",
	},
	"speargoblin" : {
		"layer" : "Ground",
		"hp" : 50,
		"prehitdelay" : 4,
		"radius" : 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
		"size" : "small",
	},
	"tombstone" : {
		"layer" : "Ground",
		"hp" : 200,
		"radius" : 17,
		"lifetimecost" : 1,
		"size" : "large",
	},
	"valkyrie" : {
		"layer" : "Ground",
		"hp" : 880,
		"radius": 12,
		"sight" : 100,
		"range" : 20,
		"size" : "medium",
	},
}

const CARDS = {
	"archers" : {
		"type" : "troop",
		"cost" : 3000,
		"unitname" : "archer",
		"unitoffsets" : [ Vector2(1, 0), Vector2(-1, 0) ],
	},
	"barbarianhut" : {
		"type" : "building",
		"cost" : 7000,
	},
	"barbarians" : {
		"type" : "troop",
		"cost" : 5000,
		"unitname" : "barbarian",
		"unitoffsets" : [ Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1) ],
	},
	"bomber" : {
		"type" : "troop",
		"cost" : 3000,
	},
	"bombtower" : {
		"type" : "building",
		"cost" : 5000,
	},
	"cannon" : {
		"type" : "building",
		"cost" : 3000,
	},
	"darkprince" : {
		"type" : "troop",
		"cost" : 4000,
	},
	"giant" : {
		"type" : "troop",
		"cost" : 5000,
	},
	"goblinhut" : {
		"type" : "building",
		"cost" : 5000,
	},
	"megaminion" : {
		"type" : "troop",
		"cost" : 3000,
	},
	"minionhorde" : {
		"type" : "troop",
		"cost" : 5000,
		"unitname" : "minion",
		"unitoffsets" : [ Vector2(0, -2), Vector2(1, -1), Vector2(-1, -1),
				Vector2(0, 2), Vector2(1, 1), Vector2(-1, 1) ],
	},
	"minions" : {
		"type" : "troop",
		"cost" : 3000,
		"unitname" : "minion",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"minipekka" : {
		"type" : "troop",
		"cost" : 4000,
	},
	"musketeer" : {
		"type" : "troop",
		"cost" : 4000,
	},
	"pekka" : {
		"type" : "troop",
		"cost" : 7000,
	},
	"prince" : {
		"type" : "troop",
		"cost" : 5000,
	},
	"skeletons" : {
		"type" : "troop",
		"cost" : 1000,
		"unitname" : "skeleton",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"speargoblins" : {
		"type" : "troop",
		"cost" : 2000,
		"unitname" : "speargoblin",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"threemusketeers" : {
		"type" : "troop",
		"cost" : 9000,
		"unitname" : "musketeer",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"tombstone" : {
		"type" : "building",
		"cost" : 3000,
	},
	"valkyrie" : {
		"type" : "troop",
		"cost" : 4000,
	},

	"laser" : {
		"type" : "spell",
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

func is_spell_card(name):
	if CARDS[name].type == "spell":
		return true
	return false

func is_unit_card(name):
	if CARDS[name].type in ["troop", "building"]:
		return true
	return false

func get_structures_of_unit(card):
	var dict = CARDS[card.Name]
	var name = card.Name
	var offsets = [ Vector2(0, 0) ]
	if dict.has("unitname"):
		name = dict.unitname
	if dict.has("unitoffsets"):
		offsets = dict.unitoffsets
	var units = []
	for offset in offsets:
		var unit = {
			"Name" : name,
			"Team" : card.Team,
			"Position" : {
				"X" : card.Position.X + offset.x * global.dict_get(global.UNITS[name], "radius", 0),
				"Y" : card.Position.Y + offset.y * global.dict_get(global.UNITS[name], "radius", 0),
			},
		}
		if unit.Team == "Home":
			unit.Position.Y = global.MAP.height - unit.Position.Y
		units.append(unit)
	return units