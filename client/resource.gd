extends Node

var unit = {
	"archer": preload("res://unit/archer/archer.tscn"),
	"barbarian": preload("res://unit/barbarian/barbarian.tscn"),
	"barbarianhut": preload("res://unit/barbarianhut/barbarianhut.tscn"),
	"base": preload("res://unit/base/base.tscn"),
	"bomber": preload("res://unit/bomber/bomber.tscn"),
	"bombtower": preload("res://unit/bombtower/bombtower.tscn"),
	"cannon": preload("res://unit/cannon/cannon.tscn"),
	"darkprince": preload("res://unit/darkprince/darkprince.tscn"),
	"giant": preload("res://unit/giant/giant.tscn"),
	"goblinhut": preload("res://unit/goblinhut/goblinhut.tscn"),
	"knightbullet": preload("res://unit/knightbullet/knightbullet.tscn"),
	"maincore": preload("res://unit/maincore/maincore.tscn"),
	"megaminion": preload("res://unit/megaminion/megaminion.tscn"),
	"minion": preload("res://unit/minion/minion.tscn"),
	"minipekka": preload("res://unit/minipekka/minipekka.tscn"),
	"musketeer": preload("res://unit/musketeer/musketeer.tscn"),
	"pekka": preload("res://unit/pekka/pekka.tscn"),
	"prince": preload("res://unit/prince/prince.tscn"),
	"scatteredbullet": preload("res://unit/scatteredbullet/scatteredbullet.tscn"),
	"shuriken": preload("res://unit/shuriken/shuriken.tscn"),
	"skeleton": preload("res://unit/skeleton/skeleton.tscn"),
	"space_z": preload("res://unit/space_z/space_z.tscn"),
	"speargoblin": preload("res://unit/speargoblin/speargoblin.tscn"),
	"subcore": preload("res://unit/subcore/subcore.tscn"),
	"tombstone": preload("res://unit/tombstone/tombstone.tscn"),
	"valkyrie": preload("res://unit/valkyrie/valkyrie.tscn"),
}

var projectile = {
	"bomber_missile": preload("res://projectile/bomber_missile.tscn"),
	"bullet": preload("res://projectile/bullet.tscn"),
	"knight_missile": preload("res://projectile/knight_missile.tscn"),
}

var unit_base = {
	"bombtower": {
		"blue": preload("res://unit/bombtower/blue_base.png"),
		"red": preload("res://unit/bombtower/red_base.png"),
	},
	"cannon": {
		"blue": preload("res://unit/cannon/blue_base.png"),
		"red": preload("res://unit/cannon/red_base.png"),
	},
}

var icon = {
	"archers": {
		"on": preload("res://icon/archers_on.png"),
		"off": preload("res://icon/archers_off.png"),
		"small": preload("res://icon/archers_small.png"),
	},
	"barbarianhut": {
		"on": preload("res://icon/barbarianhut_on.png"),
		"off": preload("res://icon/barbarianhut_off.png"),
		"small": preload("res://icon/barbarianhut_small.png"),
	},
	"barbarians": {
		"on": preload("res://icon/barbarians_on.png"),
		"off": preload("res://icon/barbarians_off.png"),
		"small": preload("res://icon/barbarians_small.png"),
	},
	"bomber": {
		"on": preload("res://icon/bomber_on.png"),
		"off": preload("res://icon/bomber_off.png"),
		"small": preload("res://icon/bomber_small.png"),
	},
	"bombtower": {
		"on": preload("res://icon/bombtower_on.png"),
		"off": preload("res://icon/bombtower_off.png"),
		"small": preload("res://icon/bombtower_small.png"),
	},
	"cannon": {
		"on": preload("res://icon/cannon_on.png"),
		"off": preload("res://icon/cannon_off.png"),
		"small": preload("res://icon/cannon_small.png"),
	},
	"darkprince": {
		"on": preload("res://icon/darkprince_on.png"),
		"off": preload("res://icon/darkprince_off.png"),
		"small": preload("res://icon/darkprince_small.png"),
	},
	"giant": {
		"on": preload("res://icon/giant_on.png"),
		"off": preload("res://icon/giant_off.png"),
		"small": preload("res://icon/giant_small.png"),
	},
	"goblinhut": {
		"on": preload("res://icon/goblinhut_on.png"),
		"off": preload("res://icon/goblinhut_off.png"),
		"small": preload("res://icon/goblinhut_small.png"),
	},
	"megaminion": {
		"on": preload("res://icon/megaminion_on.png"),
		"off": preload("res://icon/megaminion_off.png"),
		"small": preload("res://icon/megaminion_small.png"),
	},
	"minionhorde": {
		"on": preload("res://icon/minionhorde_on.png"),
		"off": preload("res://icon/minionhorde_off.png"),
		"small": preload("res://icon/minionhorde_small.png"),
	},
	"minions": {
		"on": preload("res://icon/minions_on.png"),
		"off": preload("res://icon/minions_off.png"),
		"small": preload("res://icon/minions_small.png"),
	},
	"minipekka": {
		"on": preload("res://icon/minipekka_on.png"),
		"off": preload("res://icon/minipekka_off.png"),
		"small": preload("res://icon/minipekka_small.png"),
	},
	"musketeer": {
		"on": preload("res://icon/musketeer_on.png"),
		"off": preload("res://icon/musketeer_off.png"),
		"small": preload("res://icon/musketeer_small.png"),
	},
	"pekka": {
		"on": preload("res://icon/pekka_on.png"),
		"off": preload("res://icon/pekka_off.png"),
		"small": preload("res://icon/pekka_small.png"),
	},
	"prince": {
		"on": preload("res://icon/prince_on.png"),
		"off": preload("res://icon/prince_off.png"),
		"small": preload("res://icon/prince_small.png"),
	},
	"skeletons": {
		"on": preload("res://icon/skeletons_on.png"),
		"off": preload("res://icon/skeletons_off.png"),
		"small": preload("res://icon/skeletons_small.png"),
	},
	"speargoblins": {
		"on": preload("res://icon/speargoblins_on.png"),
		"off": preload("res://icon/speargoblins_off.png"),
		"small": preload("res://icon/speargoblins_small.png"),
	},
	"threemusketeers": {
		"on": preload("res://icon/threemusketeers_on.png"),
		"off": preload("res://icon/threemusketeers_off.png"),
		"small": preload("res://icon/threemusketeers_small.png"),
	},
	"tombstone": {
		"on": preload("res://icon/tombstone_on.png"),
		"off": preload("res://icon/tombstone_off.png"),
		"small": preload("res://icon/tombstone_small.png"),
	},
	"valkyrie": {
		"on": preload("res://icon/valkyrie_on.png"),
		"off": preload("res://icon/valkyrie_off.png"),
		"small": preload("res://icon/valkyrie_small.png"),
	},
}

var effect = {
	"launch": preload("res://effect/launch.tscn"),
	"runway": preload("res://effect/runway.tscn"),
	"explosion": {
		"unit": preload("res://effect/explosion/unit.tscn"),
		"missile": preload("res://effect/explosion/missile.tscn"),
	},
}