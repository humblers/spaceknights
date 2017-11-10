extends Node

var config = ConfigFile.new()

var id

var team

const CARD_WAIT_FRAME = 5 - 1 # server send snapshot after 1 frame
const SERVER_UPDATES_PER_SECOND = 10

const MOTHERSHIP_BASE_HEIGHT = 50
const MAP = {
	"width" : 400,
	"height" : 560,
}

const LAYERS = {
	"Ground": 0,
	"Air": 1,
	"Projectile": 2,
	"UI": 100,
}

const UNITS = {
	"archer" : {
		"layer" : "Ground",
		"prehitdelay" : 4,
		"radius" : 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
		"size" : "small",
	},
	"barbarian" : {
		"layer" : "Ground",
		"radius" : 11,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"barbarianhut" : {
		"layer" : "Ground",
		"radius" : 20,
		"lifetimecost" : 2,
		"size" : "large",
	},
	"bomber" : {
		"layer" : "Ground",
		"prehitdelay" : 10,
		"radius" : 11,
		"sight" : 100,
		"range" : 90,
		"projectile" : "bomber_missile",
		"size" : "medium",
	},
	"bombtower" : {
		"layer" : "Ground",
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
		"radius" : 13,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"giant" : {
		"layer" : "Ground",
		"radius" : 28,
		"sight" : 200,
		"range" : 15,
		"size" : "xlarge",
	},
	"goblinhut" : {
		"layer" : "Ground",
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
		"prehitdelay" : 10,
		"radius" : 20,
		"sight" : 140,
		"range" : 140,
		"projectile" : "knight_missile",
	},
	"space_z" : {
		"layer" : "Air",
		"prehitdelay" : 10,
		"radius" : 31,
		"sight" : 140,
		"range" : 140,
		"projectile" : "knight_missile",
	},
	"megaminion" : {
		"layer" : "Air",
		"radius" : 20,
		"sight" : 80,
		"range" : 50,
		"size" : "large",
	},
	"minion" : {
		"layer" : "Air",
		"radius" : 10,
		"sight" : 80,
		"range" : 20,
		"size" : "small",
	},
	"minipekka" : {
		"layer" : "Ground",
		"radius" : 12,
		"sight" : 100,
		"range" : 15,
		"size" : "small",
	},
	"maincore" : {
		"layer" : "Ground",
		"radius" : 20,
		"size" : "xlarge",
	},
	"subcore" : {
		"layer" : "Ground",
		"radius" : 30,
		"size" : "xlarge",
	},
	"base" : {
		"layer" : "Ground",
	},
	"musketeer" : {
		"layer" : "Ground",
		"prehitdelay": 3,
		"radius" : 11,
		"sight" : 120,
		"range" : 120,
		"projectile" : "bullet",
		"size" : "large",
	},
	"pekka" : {
		"layer" : "Ground",
		"radius" : 13,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"prince" : {
		"layer" : "Ground",
		"radius" : 14,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"skeleton" : {
		"layer" : "Ground",
		"radius" : 6,
		"sight" : 100,
		"range" : 5,
		"size" : "small",
	},
	"speargoblin" : {
		"layer" : "Ground",
		"prehitdelay" : 4,
		"radius" : 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
		"size" : "small",
	},
	"tombstone" : {
		"layer" : "Ground",
		"radius" : 17,
		"lifetimecost" : 1,
		"size" : "large",
	},
	"valkyrie" : {
		"layer" : "Ground",
		"radius": 12,
		"sight" : 100,
		"range" : 20,
		"size" : "medium",
	},
}

const CARDS = {
	"archers" : {
		"unitname" : "archer",
		"unitoffsets" : [ Vector2(1, 0), Vector2(-1, 0) ],
	},
	"barbarianhut" : { },
	"barbarians" : {
		"unitname" : "barbarian",
		"unitoffsets" : [ Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1) ],
	},
	"bomber" : { },
	"cannon" : { },
	"darkprince" : { },
	"giant" : { },
	"goblinhut" : { },
	"megaminion" : { },
	"minionhorde" : {
		"unitname" : "minion",
		"unitoffsets" : [ Vector2(0, -2), Vector2(1, -1), Vector2(-1, -1),
				Vector2(0, 2), Vector2(1, 1), Vector2(-1, 1) ],
	},
	"minions" : {
		"unitname" : "minion",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"minipekka" : { },
	"musketeer" : { },
	"pekka" : { },
	"prince" : { },
	"skeletons" : {
		"unitname" : "skeleton",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"speargoblins" : {
		"unitname" : "speargoblin",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"threemusketeers" : {
		"unitname" : "musketeer",
		"unitoffsets" : [ Vector2(0, 1), Vector2(1, -1), Vector2(-1, -1) ],
	},
	"tombstone" : { },
	"valkyrie" : { },
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