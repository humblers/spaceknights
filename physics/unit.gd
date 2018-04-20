extends Node2D

const mass = 10
const radius = 30
const speed = 10

onready var game = get_node("..")
onready var target = get_node("../enemy")

var body

func _ready():
	body = Physics.CreateCircle(Q.FromInt(mass),
		game.PixelToWorldPosition(position),
		game.PixelToWorldValue(radius))
	body.Node = self
	get_node("circle").radius = radius
	get_node("circle").color = Color(0, 0, 1)

func Step():
	var path = Map.FindPath(body.Position, target.body.Position, body.Radius)
	if path != null:
		Map.AdjustPath(path, body.Radius)
		var dest = Map.NextCornerInPath(path, body.Position)
		#body.Velocity = Vec2.Mul(Vec2.Normalize(Vec2.Sub(dest, body.Position)), game.PixelToWorldValue(speed))
#		var speed_in_world = game.PixelToWorldValue(speed)
#		var current = Vec2.Normalize(body.Velocity)
#		var desired = Vec2.Normalize(Vec2.Sub(dest, body.Position))
#		if Vec2.Dot(current, desired) > 0 and Vec2.Length(body.Velocity) > speed_in_world:
#			return
		body.Force = Vec2.Mul(Vec2.Sub(dest, body.Position), game.PixelToWorldValue(speed))