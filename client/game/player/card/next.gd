extends Node2D

func Set(card):
	var path = loading_screen.GetCardIconPathInGame(card.Name)
	$Icon.texture = loading_screen.LoadResource(path)
	$Icon/Energy/Cost.text = str(card.Cost/1000)

func Update(ready):
	$Icon/NotReady.visible = not ready
