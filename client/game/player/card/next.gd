extends Node2D

func _ready():
	event.connect("BlueSetNext", self, "setNext")
	event.connect("BlueUpdateNext", self, "updateReady")

func setNext(card):
	var path = loading_screen.GetCardIconPathInGame(card.Name)
	$Icon.texture = loading_screen.LoadResource(path)
	$Icon/Energy/Cost.text = str(card.Cost/1000)

func updateReady(ready):
	$Icon/NotReady.visible = not ready