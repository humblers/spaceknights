extends Node2D

const mass = 10
const radius = 30
const speed = 200
const slowing_radius = 100

onready var game = get_node("..")
onready var target = get_node("../enemy")

var body

func _ready():
	body = Physics.CreateCircle(Q.FromInt(mass),
		game.PixelToWorldPosition(position),
		game.PixelToWorldValue(radius))
	body.Node = self
	body.MaxSpeed = game.PixelToWorldValue(speed)
	get_node("circle").radius = radius
	get_node("circle").color = Color(0, 0, 1)

func Step():
	var path = Map.FindPath(body.Position, target.body.Position, body.Radius)
	if path != null:
		Map.AdjustPath(path, body.Radius)
		var dest = Map.NextCornerInPath(path, body.Position)
		#body.Velocity = Vec2.Mul(Vec2.Normalize(Vec2.Sub(dest, body.Position)), game.PixelToWorldValue(speed))
		var diff = Vec2.Sub(dest, body.Position)
		var distance = Vec2.Length(diff)
		var desired = Vec2.Mul(Vec2.Normalize(diff), game.PixelToWorldValue(speed))
		desired = Vec2.Mul(desired, game.PixelToWorldValue(mass))
		if distance < game.PixelToWorldValue(slowing_radius):
			Vec2.MulInplace(desired, Q.Div(distance, game.PixelToWorldValue(slowing_radius)))
		body.Force = Vec2.Sub(desired, body.Velocity)