extends CanvasLayer

func _ready():
	event.connect("RequestPopup", self, "popUp")

func popUp(kind, args):
	match kind:
		event.PopupModalMessage:
			if len(args) == 1:
				$Modal.PopUp(args[0])
			else:
				$Modal.PopUp(args[0], args[1])
		event.PopupModalConfirm:
			$ModalConfirm.PopUp(args[0])
		event.PopupSetting:
			$Setting.PopUp()