extends Node

var config = ConfigFile.new()

var id

var team

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
	"Ground": 0,
	"GroundEffect": 1,
	"Air": 2,
	"Projectile": 3,
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
		"prehitdelay": 15,
		"radius" : 20,
		"sight" : 120,
		"range" : 120,
		"projectile" : "bullet",
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
		"layer" : "Ground",
		"hp" : 1200,
		"radius" : 20,
		"size" : "xlarge",
	},
	"subcore" : {
		"layer" : "Ground",
		"hp" : 700,
		"radius" : 30,
		"size" : "xlarge",
	},
	"base" : {
		"layer" : "Ground",
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
		"cost" : 3000,
		"unitname" : "archer",
		"unitoffsets" : [ Vector2(1, 0), Vector2(-1, 0) ],
	},
	"barbarianhut" : {
		"cost" : 7000,
	},
	"barbarians" : {
		"cost" : 5000,
		"unitname" : "barbarian",
		"unitoffsets" : [ Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1) ],
	},
	"bomber" : {
		"cost" : 3000,
	},
	"cannon" : {
		"cost" : 3000,
	},
	"darkprince" : {
		"cost" : 4000,
	},
	"giant" : {
		"cost" : 5000,
	},
	"goblinhut" : {
		"cost" : 5000,
	},
	"megaminion" : {
		"cost" : 3000,
	},
	"minionhorde" : {
		"cost" : 5000,
		"unitname" : "minion",
		"unitoffsets" : [ Vector2(0, -2), Vector2(1, -1), Vector2(-1, -1),
				Vector2(0, 2), Vector2(1, 1), Vector2(-1, 1) ],
	},
	"minions" : {
		"cost" : 3000,
		"unitname" : "minion",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"minipekka" : {
		"cost" : 4000,
	},
	"musketeer" : {
		"cost" : 4000,
	},
	"pekka" : {
		"cost" : 7000,
	},
	"prince" : {
		"cost" : 5000,
	},
	"skeletons" : {
		"cost" : 1000,
		"unitname" : "skeleton",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"speargoblins" : {
		"cost" : 2000,
		"unitname" : "speargoblin",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"threemusketeers" : {
		"cost" : 9000,
		"unitname" : "musketeer",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"tombstone" : {
		"cost" : 3000,
	},
	"valkyrie" : {
		"cost" : 4000,
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