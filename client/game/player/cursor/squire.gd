extends Node2D

func _ready():
	pass 

func set_text(name, level):
	self.get_node("Deco/NameNod/Squire").SetText("ID_%s" % name.to_upper())
	self.get_node("Deco/NameNod/Level").set_text("lvl. %s" % (level+1))
	 
