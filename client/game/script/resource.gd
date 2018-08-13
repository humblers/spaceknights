extends Node

const WORLD = preload("res://game/script/physics/world.gd")
const MAP = {
	"Thanatos": preload("res://game/script/nav/thanatos.gd")
}
const UNIT = {
	"archer": preload("res://game/unit/archer/archer.tscn"),
	"legion": preload("res://game/unit/legion/legion.tscn"),
	"shadowvision": preload("res://game/unit/shadowvision/shadowvision.tscn"),
	"nagmash": preload("res://game/unit/nagmash/nagmash.tscn"),
}
const BULLET = {
	"archer": preload("res://game/unit/archer/bullet.tscn"),
	"legion": preload("res://game/unit/legion/bullet.tscn"),
	"shadowvision": preload("res://game/unit/shadowvision/missile.tscn"),
	"nagmash": preload("res://game/unit/legion/bullet.tscn"),
}
const SKILL = {
	"legion": preload("res://game/unit/legion/bombexplosion.tscn"),
	"nagmash": preload("res://game/unit/legion/bombexplosion.tscn"),
}

const CURSOR = {
	"unit": preload("res://game/ui/unit_cursor.tscn"),
	"legion": preload("res://game/unit/legion/bomingpoint.tscn"),
	"nagmash": preload("res://game/unit/legion/bomingpoint.tscn"),
}

# temporary
const ICON = {
	"archers": preload("res://game/unit/archer/idle.png"),
	"fireball": preload("res://game/unit/legion/bomber.png"),
	"shadowvision": preload("res://game/unit/shadowvision/shadow_vision.png")
}