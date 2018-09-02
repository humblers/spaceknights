extends Node
#
#var pos1 = Vector2(-80,0)
#var pos2 = Vector2(10.7, -101.6)

var pos1 = Vector2(0,10)
var pos2 = Vector2(10, 0)
var angle

func _ready():
	angle = pos1.angle_to(pos2)
	#print(angle*2*PI)
	print(rad2deg(angle))
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
