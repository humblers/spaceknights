#extends "res://game/script/unit.gd"
extends Node2D

var game
var hp = 5000
var attack = 0
var attackInterval = 1
var name_ = "valkyrie"
var color = "Blue"
var level

var damages = {}

func New(name, team,  level, posX, posY, game):
	self.game = game
	self.level = level
	hp = InitialHp()
	set_hp()
	setLevel()

func Init(id, level, posX, posY, game):
	self.game = game
	hp = InitialHp()
	set_hp()
	setLevel()

func fire():
#	var b = $ResourcePreloader.get_resource("missile").instance()
	var b = $ResourcePreloader.get_resource("bullet").instance()
	b.Init(25, 30, "Bullet", game)
#	var duration = 0
#	for d in player.StatRatios("slowduration"):
#		duration += d
#	b.MakeFrozen(duration)
#	var damageRadius = 0
#	for r in player.StatRatios("expanddamageradius"):
#		damageRadius += scalar.Add(damageRadius, game.World().FromPixel(r))
#	b.MakeSplash(damageRadius)
	game.AddBullet(b)
	
	# client only
	b.rotation = $Rotatable.rotation
	b.global_position = $Rotatable/Body/Missile.global_position

func IsDead():
	return hp <= 0


func Update():
	attack += 1
	if attack == attackInterval:
		fire()
		attack = 0
		
func _process(delta):
	pass

func Type():
	return data.units[name_]["type"]

func PositionX():
	return self.position.x

func PositionY():
	return self.position.y


func Radius():
	return data.units[name_].get("radius", 0)

func TakeDamage(amount, damageType, attacker):
	hp -= amount
	var node_hp = get_node("Hp/HBoxContainer/VBoxContainer/%s" % color)
	node_hp.value = hp
	print(hp)
	node_hp.visible = true
	$Hp/HBoxContainer/Control.visible = true

	# client only
	if damageType == data.Decay:
		return
	damages[game.step] = 0
	$HitEffect.hit(damageType)

func Destroy():
	$AnimationPlayer.play("destroy")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func InitialHp():
	var v = data.units[name_]["hp"]
	var t = typeof(v)
	match t:
		TYPE_INT:
			return v
		TYPE_ARRAY:
			return v[level]
		_:
			print("invalid hp type")

func set_hp():
	var node_hp = get_node("Hp/HBoxContainer/VBoxContainer/%s" % color)
	node_hp.max_value = hp
	node_hp.value = hp
	get_node("Hp/HBoxContainer/VBoxContainer/%s/HpLabel" % color).text = "%d" % hp

func setLevel():
	$Hp/HBoxContainer/Control/LevelLabel.text = "%d" % (level + 1)
	if color == "Red":
		$Hp/HBoxContainer/Control.visible = true