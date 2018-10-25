extends Node

const LOBBY = preload("res://lobby/script/resource.gd")

const WORLD = preload("res://game/script/physics/world.gd")
const MAP = {
	"Thanatos": preload("res://game/script/nav/thanatos.gd")
}
const UNIT = {
	"archer": preload("res://game/unit/archer/archer.tscn"),
	"archsapper": preload("res://game/unit/archsapper/archsapper.tscn"),
	"cannon": preload("res://game/unit/cannon/cannon.tscn"),
	"footman": preload("res://game/unit/footman/footman.tscn"),
	"enforcer": preload("res://game/unit/enforcer/enforcer.tscn"),
	"gargoyle": preload("res://game/unit/gargoyle/gargoyle.tscn"),
	"giant": preload("res://game/unit/giant/giant.tscn"),
	"psabu": preload("res://game/unit/psabu/psabu.tscn"),
	"legion": preload("res://game/unit/legion/legion.tscn"),
	"shadowvision": preload("res://game/unit/shadowvision/shadowvision.tscn"),
	"nagmash": preload("res://game/unit/nagmash/nagmash.tscn"),
	"astra": preload("res://game/unit/astra/astra.tscn"),
	"judge": preload("res://game/unit/judge/judge.tscn"),
	"barrack": preload("res://game/unit/barrack/barrack.tscn"),
	"tombstone": preload("res://game/unit/tombstone/tombstone.tscn"),
	"panzerkunstler": preload("res://game/unit/panzerkunstler/panzerkunstler.tscn"),
	"jouster": preload("res://game/unit/jouster/jouster.tscn"),
	"felhound": preload("res://game/unit/felhound/felhound.tscn"),
	"trainee": preload("res://game/unit/trainee/trainee.tscn"),
	"starfire": preload("res://game/unit/starfire/starfire.tscn"),
	"pixie": preload("res://game/unit/pixie/pixie.tscn"),
	"gargoyleking": preload("res://game/unit/gargoyleking/gargoyleking.tscn"),
	"berserker": preload("res://game/unit/berserker/berserker.tscn"),
	"ogre": preload("res://game/unit/ogre/ogre.tscn"),
	"wasp": preload("res://game/unit/wasp/wasp.tscn"),
	"frost": preload("res://game/unit/frost/frost.tscn"),
	"champion": preload("res://game/unit/champion/champion.tscn"),
	"sentry": preload("res://game/unit/sentry/sentry.tscn"),
	"lancer": preload("res://game/unit/lancer/lancer.tscn"),
	"drillram": preload("res://game/unit/drillram/drillram.tscn"),
	"blaster": preload("res://game/unit/blaster/blaster.tscn"),
	"archengineer": preload("res://game/unit/archengineer/archengineer.tscn"),
	"blastturret": preload("res://game/unit/blastturret/blastturret.tscn"),
	"ironcoffin": preload("res://game/unit/ironcoffin/ironcoffin.tscn"),
	"sentryshelter": preload("res://game/unit/sentryshelter/sentryshelter.tscn"),
	"pixieking": preload("res://game/unit/pixieking/pixieking.tscn"),
	"pixiegeode": preload("res://game/unit/pixiegeode/pixiegeode.tscn"),
}
const BULLET = {
	"archer": preload("res://game/unit/archer/bullet.tscn"),
	"archsapper": preload("res://game/unit/archsapper/cannon_bullet.tscn"),
	"cannon": preload("res://game/unit/cannon/bullet.tscn"),
	"legion": preload("res://game/unit/legion/bullet.tscn"),
	"shadowvision": preload("res://game/unit/shadowvision/missile.tscn"),
	"frost": preload("res://game/unit/frost/bullet.tscn"),
	"sentry": preload("res://game/unit/sentry/bullet.tscn"),
	"judge": preload("res://game/unit/judge/bullet.tscn"),
	"blaster": preload("res://game/unit/blaster/missile.tscn"),
	"archengineer": preload("res://game/unit/archengineer/energy_orb.tscn"),
	"blastturret": preload("res://game/unit/blastturret/missile.tscn"),
	"ironcoffin": preload("res://game/unit/ironcoffin/missile.tscn"),
	"pixieking": preload("res://game/unit/pixieking/bullet.tscn"),
	"lancer": preload("res://game/unit/lancer/missile.tscn"),
	# temporary, no bullet for below units
	"starfire": preload("res://game/unit/starfire/bullet.tscn"),
}
const SKILL = {
	"legion": preload("res://game/unit/legion/bomb_explosion.tscn"),
	"judge": preload("res://game/unit/judge/bulletrain.tscn"),
	"frost": preload("res://game/unit/frost/freeze.tscn"),
	"lancer": preload("res://game/unit/lancer/napalm.tscn"),
}
const PASSIVE = {
	"lancer": preload("res://game/unit/lancer/deathcarpet.tscn"),
}

const CURSOR = {
	"unit": preload("res://game/ui/unit_cursor.tscn"),
	"archsapper": preload("res://game/unit/archsapper/target_square.tscn"),
	"legion": preload("res://game/unit/legion/boming_point.tscn"),
	"nagmash": preload("res://game/unit/nagmash/target_circle.tscn"),
	"astra": preload("res://game/unit/astra/target_square.tscn"),
	"judge": preload("res://game/unit/judge/bomingpoint.tscn"),
	"tombstone": preload("res://game/unit/tombstone/target_circle.tscn"),
	"frost": preload("res://game/unit/frost/bombing_point.tscn"),
	"lancer": preload("res://game/unit/lancer/target_square.tscn"),
	"archengineer": preload("res://game/unit/archengineer/target_square.tscn"),
	"ironcoffin": preload("res://game/unit/ironcoffin/target_square.tscn"),
	"pixieking": preload("res://game/unit/pixieking/target_circle.tscn"),
}

# temporary
const ICON = {
	# Knight
	"archengineer": preload("res://game/ui/unit_icon/archengineer.png"),
	"archsapper": preload("res://game/ui/unit_icon/archsapper.png"),
	"astra": preload("res://game/ui/unit_icon/astra.png"),
	"frost": preload("res://game/ui/unit_icon/frost.png"),
	"ironcoffin": preload("res://game/ui/unit_icon/ironcoffin.png"),
	"judge": preload("res://game/ui/unit_icon/judge.png"),
	"lancer": preload("res://game/ui/wingskill_icon/napalm.png"),
	"legion": preload("res://game/ui/unit_icon/legion.png"),
	"nagmash": preload("res://game/ui/unit_icon/nagmash.png"),
	"pixieking": preload("res://game/ui/unit_icon/pixieking.png"),
	"tombstone": preload("res://game/ui/unit_icon/tombstone.png"),

	# Else(Troop)
	"archers": preload("res://game/ui/unit_icon/archer.png"),
	"berserker": preload("res://game/ui/unit_icon/berserker.png"),
	"blaster": preload("res://game/ui/unit_icon/blaster.png"),
	"champion": preload("res://game/ui/unit_icon/champion.png"),
	"drillram": preload("res://game/ui/unit_icon/drillram.png"),
	"enforcer": preload("res://game/ui/unit_icon/enforcer.png"),
	"felhound": preload("res://game/ui/unit_icon/felhound.png"),
	"footmans": preload("res://game/ui/unit_icon/footman.png"),
	"gargoylehorde": preload("res://game/ui/unit_icon/gargoyle.png"),
	"gargoyleking": preload("res://game/ui/unit_icon/gargoyleking.png"),
	"giant": preload("res://game/ui/unit_icon/giant.png"),
	"jouster": preload("res://game/ui/unit_icon/jouster.png"),
	"ogre": preload("res://game/ui/unit_icon/ogre.png"),
	"panzerkunstler": preload("res://game/ui/unit_icon/panzerkunstler.png"),
	"pixie": preload("res://game/ui/unit_icon/pixie.png"),
	"psabu": preload("res://game/ui/unit_icon/psabu.png"),
	"sentry": preload("res://game/ui/unit_icon/sentry.png"),
	"shadowvision": preload("res://game/ui/unit_icon/shadowvision.png"),
	"starfire": preload("res://game/ui/unit_icon/starfire.png"),
	"trainee": preload("res://game/ui/unit_icon/trainee.png"),
	"threestarfires": preload("res://game/ui/unit_icon/threestarfires.png"),
	"wasp": preload("res://game/ui/unit_icon/wasp.png"),
}
