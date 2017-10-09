extends Node

var id
var team

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
		"type" : "Troop",
		"layer" : "Ground",
		"prehitdelay" : 11,
		"radius" : 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
		"size" : "small",
	},
	"barbarian" : {
		"type" : "Troop",
		"layer" : "Ground",
		"radius" : 11,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"bomber" : {
		"type" : "Troop",
		"layer" : "Ground",
		"radius" : 11,
		"sight" : 100,
		"range" : 100,
		"size" : "medium",
	},
	"cannon" : {
		"type" : "Building",
		"layer" : "Ground",
		"prehitdelay": 5,
		"radius" : 20,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
		"lifetimecost" : 1,
		"size" : "medium",
	},
	"giant" : {
		"type" : "Troop",
		"layer" : "Ground",
		"radius" : 28,
		"sight" : 200,
		"range" : 15,
		"size" : "xlarge",
	},
	"shuriken" : {
		"type" : "Knight",
		"layer" : "Air",
		"radius" : 20,
	},
	"space_z" : {
		"type" : "Knight",
		"layer" : "Air",
		"radius" : 31,
	},
	"megaminion" : {
		"type" : "Troop",
		"layer" : "Air",
		"radius" : 20,
		"sight" : 80,
		"range" : 50,
		"size" : "large",
	},
	"minipekka" : {
		"type" : "Troop",
		"layer" : "Ground",
		"radius" : 12,
		"sight" : 100,
		"range" : 15,
		"size" : "small",
	},
	"maincore" : {
		"type" : "Building",
		"layer" : "Ground",
		"radius" : 20,
		"size" : "xlarge",
	},
	"subcore" : {
		"type" : "Building",
		"layer" : "Ground",
		"radius" : 30,
		"size" : "xlarge",
	},
	"base" : {
		"type" : "Base",
		"layer" : "Ground",
	},
	"musketeer" : {
		"type" : "Troop",
		"layer" : "Ground",
		"prehitdelay": 10,
		"radius" : 11,
		"sight" : 120,
		"range" : 120,
		"projectile" : "bullet",
		"size" : "large",
	},
	"pekka" : {
		"type" : "Troop",
		"layer" : "Ground",
		"radius" : 13,
		"sight" : 100,
		"range" : 15,
		"size" : "medium",
	},
	"skeleton" : {
		"type" : "Troop",
		"layer" : "Ground",
		"radius" : 6,
		"sight" : 100,
		"range" : 5,
		"size" : "small",
	},
	"speargoblin" : {
		"type" : "Troop",
		"layer" : "Ground",
		"prehitdelay" : 12,
		"radius" : 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
		"size" : "small",
	},
	"valkyrie" : {
		"type" : "Troop",
		"layer" : "Ground",
		"radius": 12,
		"sight" : 100,
		"range" : 20,
		"size" : "medium",
	},
}

static func dict_get(dict, key, not_found_val=null):
	if dict.has(key):
		return dict[key]
	return not_found_val