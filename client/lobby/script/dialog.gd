extends CanvasLayer

func _ready():
	event.connect("RequestDialog", self, "showDialog")

func showDialog(kind, args):
	match kind:
		event.DialogCardUpgrade:
			$CardUpgrade.PopUp(args[0])
		event.DialogChestOpen:
			if len(args) == 3:
				$ChestOpen.PopUp(args[0], args[1], args[2])
			else:
				$ChestOpen.PopUp(args[0], args[1], args[2], args[3])
		event.DialogMatchwating:
			$MatchWating.Pop()