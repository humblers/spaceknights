extends TextureRect

func init(level, experience, galacticoin, dimensium):
	$Level.text = "%d" % (level + 1) # level based on 0
	$Level/Exp.text = "%d/xxx" % experience
	$Galacticoin.text = "%d" % galacticoin
	$Dimensium.text = "%d" % dimensium