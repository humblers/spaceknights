extends Node

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
}
const BULLET = {
	"archer": preload("res://game/unit/archer/bullet.tscn"),
	"archsapper": preload("res://game/unit/archsapper/cannonbullet.tscn"),
	"cannon": preload("res://game/unit/cannon/bullet.tscn"),
	"legion": preload("res://game/unit/legion/bullet.tscn"),
	"shadowvision": preload("res://game/unit/shadowvision/missile.tscn"),
	"nagmash": preload("res://game/unit/archer/bullet.tscn"),
	"astra": preload("res://game/unit/astra/shot.tscn"),
	# temporary, no bullet for below units
	"judge": preload("res://game/unit/archer/bullet.tscn"),
	"tombstone": preload("res://game/unit/archer/bullet.tscn"),
	"starfire": preload("res://game/unit/astra/shot.tscn"),
}
const SKILL = {
	"legion": preload("res://game/unit/legion/bombexplosion.tscn"),
	"judge": preload("res://game/unit/judge/arealshot.tscn"),
}

const CURSOR = {
	"unit": preload("res://game/ui/unit_cursor.tscn"),
	"archsapper": preload("res://game/unit/archsapper/targetsquare.tscn"),
	"legion": preload("res://game/unit/legion/bomingpoint.tscn"),
	"nagmash": preload("res://game/unit/nagmash/targetcircle.tscn"),
	"astra": preload("res://game/unit/astra/targetsquare.tscn"),
	"judge": preload("res://game/unit/judge/bomingpoint.tscn"),
	"tombstone": preload("res://game/unit/tombstone/targetcircle.tscn"),
}

# temporary
const ICON = {
	"archers": preload("res://game/ui/unit_icon/archer.png"),
	"cannon": preload("res://game/ui/unit_icon/archsapper.png"),
	"fireball": preload("res://game/ui/unit_icon/legion.png"),
	"gargoylehorde": preload("res://game/ui/unit_icon/gargoyle.png"),
	"giant": preload("res://game/ui/unit_icon/giant.png"),
	"shadowvision": preload("res://game/ui/unit_icon/shadowvision.png"),
	"unload": preload("res://game/ui/unit_icon/nagmash.png"),
	"footmans": preload("res://game/ui/unit_icon/footman.png"),
	"psabu": preload("res://game/ui/unit_icon/psabu.png"),
	"megalaser": preload("res://game/ui/unit_icon/astra.png"),
	"bulletrain": preload("res://game/ui/unit_icon/judge.png"),
	"barrack": preload("res://game/ui/unit_icon/tombstone.png"),
	"panzerkunstler": preload("res://game/ui/unit_icon/panzerkunstler.png"),
	"jouster": preload("res://game/ui/unit_icon/jouster.png"),
	"enforcer": preload("res://game/ui/unit_icon/enforcer.png"),
	"felhound": preload("res://game/ui/unit_icon/felhound.png"),
	"trainee": preload("res://game/ui/unit_icon/trainee.png"),
	"starfire": preload("res://game/ui/unit_icon/starfire.png"),
	"threestarfires": preload("res://game/ui/unit_icon/threestarfires.png"),
	"pixie": preload("res://game/ui/unit_icon/pixie.png"),
	"gargoyleking": preload("res://game/ui/unit_icon/gargoyleking.png"),
	"berserker": preload("res://game/ui/unit_icon/berserker.png"),
	"ogre": preload("res://game/ui/unit_icon/ogre.png"),
	"wasp": preload("res://game/ui/unit_icon/wasp.png"),
}
