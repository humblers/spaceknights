extends CanvasLayer

func _ready():
	event.connect("RequestDialog", self, "showDialog")

func showDialog(kind, args):
	match kind:
		event.DialogCardUpgrade:
			pass
		event.DialogChestOpen:
			pass
		event.DialogMatchwating:
			$MatchWating.Pop()