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

var spell = {
	"laser": preload("res://spell/laser.tscn"),
}

var projectile = {
	"bomber_missile": preload("res://projectile/bomber_missile.tscn"),
	"bombtower_missile": preload("res://projectile/bombtower_missile.tscn"),
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
		"on": {
			"normal" : preload("res://icon/archers_on.png"),
			"pressed" : preload("res://icon/archers_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/archers_off.png"),
			"pressed" : preload("res://icon/archers_off_pressed.png"),
		},
		"small": preload("res://icon/archers_small.png"),
	},
	"barbarianhut": {
		"on": {
			"normal" : preload("res://icon/barbarianhut_on.png"),
			"pressed" : preload("res://icon/barbarianhut_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/barbarianhut_off.png"),
			"pressed" : preload("res://icon/barbarianhut_off_pressed.png"),
		},
		"small": preload("res://icon/barbarianhut_small.png"),
	},
	"barbarians": {
		"on": {
			"normal" : preload("res://icon/barbarians_on.png"),
			"pressed" : preload("res://icon/barbarians_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/barbarians_off.png"),
			"pressed" : preload("res://icon/barbarians_off_pressed.png"),
		},
		"small": preload("res://icon/barbarians_small.png"),
	},
	"bomber": {
		"on": {
			"normal" : preload("res://icon/bomber_on.png"),
			"pressed" : preload("res://icon/bomber_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/bomber_off.png"),
			"pressed" : preload("res://icon/bomber_off_pressed.png"),
		},
		"small": preload("res://icon/bomber_small.png"),
	},
	"bombtower": {
		"on": {
			"normal" : preload("res://icon/bombtower_on.png"),
			"pressed" : preload("res://icon/bombtower_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/bombtower_off.png"),
			"pressed" : preload("res://icon/bombtower_off_pressed.png"),
		},
		"small": preload("res://icon/bombtower_small.png"),
	},
	"cannon": {
		"on": {
			"normal" : preload("res://icon/cannon_on.png"),
			"pressed" : preload("res://icon/cannon_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/cannon_off.png"),
			"pressed" : preload("res://icon/cannon_off_pressed.png"),
		},
		"small": preload("res://icon/cannon_small.png"),
	},
	"darkprince": {
		"on": {
			"normal" : preload("res://icon/darkprince_on.png"),
			"pressed" : preload("res://icon/darkprince_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/darkprince_off.png"),
			"pressed" : preload("res://icon/darkprince_off_pressed.png"),
		},
		"small": preload("res://icon/darkprince_small.png"),
	},
	"giant": {
		"on": {
			"normal" : preload("res://icon/giant_on.png"),
			"pressed" : preload("res://icon/giant_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/giant_off.png"),
			"pressed" : preload("res://icon/giant_off_pressed.png"),
		},
		"small": preload("res://icon/giant_small.png"),
	},
	"goblinhut": {
		"on": {
			"normal" : preload("res://icon/goblinhut_on.png"),
			"pressed" : preload("res://icon/goblinhut_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/goblinhut_off.png"),
			"pressed" : preload("res://icon/goblinhut_off_pressed.png"),
		},
		"small": preload("res://icon/goblinhut_small.png"),
	},
	"megaminion": {
		"on": {
			"normal" : preload("res://icon/megaminion_on.png"),
			"pressed" : preload("res://icon/megaminion_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/megaminion_off.png"),
			"pressed" : preload("res://icon/megaminion_off_pressed.png"),
		},
		"small": preload("res://icon/megaminion_small.png"),
	},
	"minionhorde": {
		"on": {
			"normal" : preload("res://icon/minionhorde_on.png"),
			"pressed" : preload("res://icon/minionhorde_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/minionhorde_off.png"),
			"pressed" : preload("res://icon/minionhorde_off_pressed.png"),
		},
		"small": preload("res://icon/minionhorde_small.png"),
	},
	"minions": {
		"on": {
			"normal" : preload("res://icon/minions_on.png"),
			"pressed" : preload("res://icon/minions_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/minions_off.png"),
			"pressed" : preload("res://icon/minions_off_pressed.png"),
		},
		"small": preload("res://icon/minions_small.png"),
	},
	"minipekka": {
		"on": {
			"normal" : preload("res://icon/minipekka_on.png"),
			"pressed" : preload("res://icon/minipekka_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/minipekka_off.png"),
			"pressed" : preload("res://icon/minipekka_off_pressed.png"),
		},
		"small": preload("res://icon/minipekka_small.png"),
	},
	"musketeer": {
		"on": {
			"normal" : preload("res://icon/musketeer_on.png"),
			"pressed" : preload("res://icon/musketeer_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/musketeer_off.png"),
			"pressed" : preload("res://icon/musketeer_off_pressed.png"),
		},
		"small": preload("res://icon/musketeer_small.png"),
	},
	"pekka": {
		"on": {
			"normal" : preload("res://icon/pekka_on.png"),
			"pressed" : preload("res://icon/pekka_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/pekka_off.png"),
			"pressed" : preload("res://icon/pekka_off_pressed.png"),
		},
		"small": preload("res://icon/pekka_small.png"),
	},
	"prince": {
		"on": {
			"normal" : preload("res://icon/prince_on.png"),
			"pressed" : preload("res://icon/prince_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/prince_off.png"),
			"pressed" : preload("res://icon/prince_off_pressed.png"),
		},
		"small": preload("res://icon/prince_small.png"),
	},
	"skeletons": {
		"on": {
			"normal" : preload("res://icon/skeletons_on.png"),
			"pressed" : preload("res://icon/skeletons_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/skeletons_off.png"),
			"pressed" : preload("res://icon/skeletons_off_pressed.png"),
		},
		"small": preload("res://icon/skeletons_small.png"),
	},
	"speargoblins": {
		"on": {
			"normal" : preload("res://icon/speargoblins_on.png"),
			"pressed" : preload("res://icon/speargoblins_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/speargoblins_off.png"),
			"pressed" : preload("res://icon/speargoblins_off_pressed.png"),
		},
		"small": preload("res://icon/speargoblins_small.png"),
	},
	"threemusketeers": {
		"on": {
			"normal" : preload("res://icon/threemusketeers_on.png"),
			"pressed" : preload("res://icon/threemusketeers_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/threemusketeers_off.png"),
			"pressed" : preload("res://icon/threemusketeers_off_pressed.png"),
		},
		"small": preload("res://icon/threemusketeers_small.png"),
	},
	"tombstone": {
		"on": {
			"normal" : preload("res://icon/tombstone_on.png"),
			"pressed" : preload("res://icon/tombstone_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/tombstone_off.png"),
			"pressed" : preload("res://icon/tombstone_off_pressed.png"),
		},
		"small": preload("res://icon/tombstone_small.png"),
	},
	"valkyrie": {
		"on": {
			"normal" : preload("res://icon/valkyrie_on.png"),
			"pressed" : preload("res://icon/valkyrie_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/valkyrie_off.png"),
			"pressed" : preload("res://icon/valkyrie_off_pressed.png"),
		},
		"small": preload("res://icon/valkyrie_small.png"),
	},
	"laser" : {
		"on": {
			"normal" : preload("res://icon/laser_on.png"),
			"pressed" : preload("res://icon/laser_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/laser_off.png"),
			"pressed" : preload("res://icon/laser_off_pressed.png"),
		},
		"small": preload("res://icon/laser_small.png"),
	},
	"moveknight" : {
		"on": {
			"normal" : preload("res://icon/moveknight_on.png"),
			"pressed" : preload("res://icon/moveknight_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/moveknight_off.png"),
			"pressed" : preload("res://icon/moveknight_off.png"),
		},
		"small": null,
	},
	"shoot" : {
		"on": {
			"normal" : preload("res://icon/shoot_on.png"),
			"pressed" : preload("res://icon/shoot_on_pressed.png"),
		},
		"off": {
			"normal" : preload("res://icon/shoot_off.png"),
			"pressed" : preload("res://icon/shoot_on_pressed.png"),
		},
		"small": null,
	},
}

var effect = {
	"launch": preload("res://effect/launch.tscn"),
	"runway": preload("res://effect/runway.tscn"),
	"lock_on": preload("res://effect/lock_on.tscn"),
	"explosion": {
		"unit": preload("res://effect/explosion/unit.tscn"),
		"missile": preload("res://effect/explosion/missile.tscn"),
	},
}