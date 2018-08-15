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
	"legion": preload("res://game/unit/legion/legion.tscn"),
	"shadowvision": preload("res://game/unit/shadowvision/shadowvision.tscn"),
	"nagmash": preload("res://game/unit/nagmash/nagmash.tscn"),
	"astra": preload("res://game/unit/astra/astra.tscn"),
}
const BULLET = {
	"archer": preload("res://game/unit/archer/bullet.tscn"),
	"cannon": preload("res://game/unit/cannon/bullet.tscn"),
	"legion": preload("res://game/unit/legion/bullet.tscn"),
	"shadowvision": preload("res://game/unit/shadowvision/missile.tscn"),
	"nagmash": preload("res://game/unit/archer/bullet.tscn"),
	"astra": preload("res://game/unit/astra/shot.tscn"),
}
const SKILL = {
	"legion": preload("res://game/unit/legion/bombexplosion.tscn"),
}

const CURSOR = {
	"unit": preload("res://game/ui/unit_cursor.tscn"),
	"archsapper": preload("res://game/unit/archsapper/targetsquare.tscn"),
	"legion": preload("res://game/unit/legion/bomingpoint.tscn"),
	"nagmash": preload("res://game/unit/nagmash/targetcircle.tscn"),
	"astra": preload("res://game/unit/astra/targetsquare.tscn"),
}

# temporary
const ICON = {
	"archers": preload("res://game/unit/archer/idle.png"),
	"cannon": preload("res://game/ui/unit_icon/archsapper.png"),
	"fireball": preload("res://game/unit/legion/bomber.png"),
	"shadowvision": preload("res://game/unit/shadowvision/shadow_vision.png"),
	"unload": preload("res://game/unit/nagmash/body.png"),
	"footmans": preload("res://game/unit/nagmash/footman_dummy.png"),
	"megalaser": preload("res://game/ui/unit_icon/astra.png"),
}