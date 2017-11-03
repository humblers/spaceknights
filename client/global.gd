extends Node

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
		"damageradius": 25,
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
		"radius" : 20,
	},
	"space_z" : {
		"layer" : "Air",
		"radius" : 31,
	},
	"megaminion" : {
		"layer" : "Air",
		"radius" : 20,
		"sight" : 80,
		"range" : 50,
		"size" : "large",
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
	"valkyrie" : {
		"layer" : "Ground",
		"radius": 12,
		"sight" : 100,
		"range" : 20,
		"size" : "medium",
	},
}

func _ready():
	randomize()

static func dict_get(dict, key, not_found_val=null):
	if dict.has(key):
		return dict[key]
	return not_found_val

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