extends Node2D

func _ready():
	pass 

func set_level(level):
	self.get_node("Deco/NameNod/Level").set_text("lvl. %s" % (level+1)) 
