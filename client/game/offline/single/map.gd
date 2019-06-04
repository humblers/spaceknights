extends Control

var hero
var prev_pos
var hero_prev_pos
var pressed = false

func _ready():
	connect("gui_input", self, "handle_map_input")
	
func initHero(hero):
	self.hero = hero
	print(hero)
	
func handle_map_input(ev):
	var prev_pressed = pressed
	if ev is InputEventMouseButton:
		pressed = ev.pressed
		if pressed:
			if !prev_pressed:
				hero_prev_pos = hero.global_position
				prev_pos = self.get_local_mouse_position()
		else:
			
			return
	if ev is InputEventMouseMotion and pressed:
		on_dragged(ev)
		
func on_dragged(ev):
	var y = ev.position.y
	var bottom = self.rect_position.y + self.rect_size.y
	var dist = rect_position.y - bottom

	if y < -dist:
		var pos = self.get_local_mouse_position()
		set_hero_pos(pos)
		
	else:
		return
		
func set_hero_pos(pos):
	hero.global_position = hero_prev_pos  + (pos - prev_pos)