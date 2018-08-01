extends Node

const WORLD = preload("res://game/script/physics/world.gd")
const MAP = {
	"Thanatos": preload("res://game/script/nav/thanatos.gd")
}
const UNIT = {
	"archer": preload("res://game/unit/archer/archer.tscn"),
	"legion": preload("res://game/unit/legion/legion.tscn"),
}
const BULLET = {
	"archer": preload("res://game/unit/archer/bullet.tscn"),
	"legion": preload("res://game/unit/legion/bullet.tscn"),
}
const SKILL = {
	"legion": preload("res://game/unit/legion/bomb_explosion.tscn"),
}

# temporary
const ICON = {
	"archers": preload("res://game/unit/archer/idle.png"),
	"fireball": preload("res://game/unit/legion/bomber.png"),
}