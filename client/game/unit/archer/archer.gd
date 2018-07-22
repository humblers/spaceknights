extends Node2D

onready var id = self.name

export(String, "home", "visitor") var team
export var level = 0
export var hp = 0
export var target_id = 0
export var attack = 0

var game
var body

func init(id, team, level, posX, posY, game):
	self.id = id
	self.team = team
	self.level = level
	self.hp = stat.archer.hp[level]
	self.game = game
	self.body = game.world.AddCircle(
		scalar.FromInt(stat.archer.mass),
		game.world.FromPixel(stat.archer.radius),
		game.world.FromPixel(posX),
		game.world.FromPixel(posY)
	)

func target():
	return game.FindUnit(target_id)
	
func Update():
	if attack > 0:
		handleAttack()
	else:
		var t = target()
		if t == null:
			findTargetAndDoAction()
		else:
			if withinRange(t):
				handleAttack()
			else:
				findTargetAndDoAction()

func handleAttack():
	if attack == stat.archer.preattackdelay:
		var t = target()
		if t != null and withinRange(t):
			fire()
		else:
			attack = 0
			return
	attack += 1
	if attack > stat.archer.attackinterval:
		attack = 0

func fire():
	var b = preload("res://game/unit/archer/bullet.tscn").instance()
	b.init(target_id, stat.archer.bulletlifetime, stat.archer.damage)
	game.AddBullet(b)
