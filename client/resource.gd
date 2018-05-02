extends Node

var game = preload("res://game.tscn")
const unit_material = preload("res://unit/material.tres")
var unit = {
	"archer": preload("res://unit/archer/archer.tscn"),
	"barbarian": preload("res://unit/barbarian/main.tscn"),
	"barbarianhut": preload("res://unit/barbarianhut/barbarianhut.tscn"),
	"bomber": preload("res://unit/bomber/bomber.tscn"),
	"bombtower": preload("res://unit/bombtower/bombtower.tscn"),
	"cannon": preload("res://unit/cannon/cannon.tscn"),
	"darkprince": preload("res://unit/darkprince/darkprince.tscn"),
	"freezer": preload("res://unit/freezer/freezer.tscn"),
	"giant": preload("res://unit/giant/giant.tscn"),
	"goblinhut": preload("res://unit/goblinhut/goblinhut.tscn"),
	"hogrider": preload("res://unit/hogrider/hogrider.tscn"),
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
	"fireball": preload("res://spell/fireball.tscn"),
	"freeze": preload("res://spell/freeze/freeze.tscn"),
}

var projectile = {
	"bomber_missile": preload("res://projectile/bomber_missile.tscn"),
	"bombtower_missile": preload("res://projectile/bombtower_missile.tscn"),
	"bullet": preload("res://projectile/bullet.tscn"),
	"knight_missile": preload("res://projectile/knight_missile.tscn"),
}

var effect = {
	"explosion": {
		"unit": preload("res://effect/explosion/unit.tscn"),
		"missile": preload("res://effect/explosion/missile.tscn"),
	},
	"spell_indicator": preload("res://spell_indicator.tscn"),
}