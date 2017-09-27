extends Node

var id
var team

const SERVER_UPDATES_PER_SECOND = 10

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
		"prehitdelay" : 11,
		"radius" : 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
	},
	"barbarian" : {
		"layer" : "Ground",
		"radius" : 11,
		"sight" : 100,
		"range" : 15,
	},
	"bomber" : {
		"layer" : "Ground",
		"radius" : 11,
		"sight" : 100,
		"range" : 100,
	},
	"cannon" : {
		"layer" : "Ground",
		"prehitdelay": 5,
		"radius" : 20,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
		"lifetimecost" : 1,
	},
	"giant" : {
		"layer" : "Ground",
		"radius" : 28,
		"sight" : 200,
		"range" : 15,
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
	},
	"minipekka" : {
		"layer" : "Ground",
		"radius" : 12,
		"sight" : 100,
		"range" : 15,
	},
	"maincore" : {
		"layer" : "Ground",
		"radius" : 20,
	},
	"subcore" : {
		"layer" : "Ground",
		"radius" : 30,
	},
	"base" : {
		"layer" : "Ground",
	},
	"musketeer" : {
		"layer" : "Ground",
		"prehitdelay": 10,
		"radius" : 11,
		"sight" : 120,
		"range" : 120,
		"projectile" : "bullet",
	},
	"pekka" : {
		"layer" : "Ground",
		"radius" : 13,
		"sight" : 100,
		"range" : 15,
	},
	"skeleton" : {
		"layer" : "Ground",
		"radius" : 6,
		"sight" : 100,
		"range" : 5,
	},
	"speargoblin" : {
		"layer" : "Ground",
		"prehitdelay" : 12,
		"radius" : 9,
		"sight" : 100,
		"range" : 100,
		"projectile" : "bullet",
	},
	"valkyrie" : {
		"layer" : "Ground",
		"radius": 12,
		"sight" : 100,
		"range" : 20,
	},
}