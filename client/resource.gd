extends Node

const game = preload("res://game.tscn")

const unit_material = preload("res://unit/material.tres")
const unit_outline = preload("res://unit/outline.tres")

var unit = {
	"archer": preload("res://unit/archer/archer.tscn"),
	"footman": preload("res://unit/footman/footman.tscn"),
	"barrack": preload("res://unit/barrack/barrack.tscn"),
	"blaster": preload("res://unit/blaster/blaster.tscn"),
	"blastturret": preload("res://unit/blastturret/blastturret.tscn"),
	"cannon": preload("res://unit/cannon/cannon.tscn"),
	"champion": preload("res://unit/champion/champion.tscn"),
	"frost": preload("res://unit/frost/frost.tscn"),
	"giant": preload("res://unit/giant/giant.tscn"),
	"sentryshelter": preload("res://unit/sentryshelter/sentryshelter.tscn"),
	"drillram": preload("res://unit/drillram/drillram.tscn"),
	"knightbullet": preload("res://unit/knightbullet/knightbullet.tscn"),
	"gargoyleking": preload("res://unit/gargoyleking/gargoyleking.tscn"),
	"gargoyle": preload("res://unit/gargoyle/gargoyle.tscn"),
	"berserker": preload("res://unit/berserker/berserker.tscn"),
	"starfire": preload("res://unit/starfire/starfire.tscn"),
	"ogre": preload("res://unit/ogre/ogre.tscn"),
	"jouster": preload("res://unit/jouster/jouster.tscn"),
	"legion": preload("res://unit/legion/legion.tscn"),
	"pixie": preload("res://unit/pixie/pixie.tscn"),
	"astra": preload("res://unit/astra/astra.tscn"),
	"sentry": preload("res://unit/sentry/sentry.tscn"),
	"pixiegeode": preload("res://unit/pixiegeode/pixiegeode.tscn"),
	"enforcer": preload("res://unit/enforcer/enforcer.tscn"),
	"felhound": preload("res://unit/felhound/felhound.tscn"),
	"judge": preload("res://unit/judge/judge.tscn"),
	"lancer": preload("res://unit/lancer/lancer.tscn"),
	"nagmash": preload("res://unit/nagmash/nagmash.tscn"),
	"panzerkunstler": preload("res://unit/panzerkunstler/panzerkunstler.tscn"),
	"psabu": preload("res://unit/psabu/psabu.tscn"),
	"shadowvision": preload("res://unit/shadowvision/shadowvision.tscn"),
	"trainee": preload("res://unit/trainee/trainee.tscn"),
	"wasp": preload("res://unit/wasp/wasp.tscn"),
}

var spell = {
	"laser": preload("res://spell/laser.tscn"),
	"fireball": preload("res://spell/fireball.tscn"),
	"freeze": preload("res://spell/freeze/freeze.tscn"),
}

var projectile = {
	"archer" : preload("res://unit/archer/bullet.tscn"),
	"cannon" : preload("res://unit/cannon/bullet.tscn"),
	"frost" : preload("res://unit/frost/bullet.tscn"),
	"starfire" : preload("res://unit/starfire/bullet.tscn"),
	"sentry" : preload("res://unit/sentry/bullet.tscn"),
	"legion" : preload("res://unit/legion/bullet.tscn"),
	"bomber_missile": preload("res://projectile/bomber_missile.tscn"),
	"bombtower_missile": preload("res://projectile/bombtower_missile.tscn"),
	"bullet": preload("res://projectile/bullet.tscn"),
	"knight_missile": preload("res://projectile/knight_missile.tscn"),
}

var effect = {
	"explosion": {
		"unit": {
			"xlarge" : preload("res://effect/explosion/xlarge.tscn"),
			"medium" : preload("res://effect/explosion/medium.tscn"),
			"small" : preload("res://effect/explosion/small.tscn"),
		}
	},
	"spell_indicator": preload("res://spell_indicator.tscn"),
}

const effect_script = preload("res://effect/effect.gd")
const sound_script = preload("res://sound/sound.gd")