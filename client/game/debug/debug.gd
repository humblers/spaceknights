extends Control

var unit
var game

func init(unit, game):
	self.unit = unit
	self.game = game
	game.connect("debug_option_changed", self, "update")

func _draw():
	if game.show_radius:
		static_func.draw_circle_arc(self, Vector2(0, 0), unit._radius(), 0, 360, Color(1, 0, 0))
	if game.show_range:
		static_func.draw_circle_arc(self, Vector2(0, 0), unit._range(), 0, 360, Color(0, 1, 0))
	if game.show_sight:
		static_func.draw_circle_arc(self, Vector2(0, 0), unit._sight(), 0, 360, Color(0, 0, 1))
