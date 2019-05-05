extends "res://lobby/script/page_container.gd"

var cur_page = "Battle"

func _ready():
	event.connect("PageSelected", self, "setCurPage")
	event.connect("RequestPoupInContents", self, "popUp")

func setCurPage(page):
	cur_page = page

func popUp(kind, args):
	var size = rect_size
	if size.x < PAGE_WIDTH_MIN:
		size.x = PAGE_WIDTH_MIN
	$PopUp.rect_position.x = size.x * PAGES[cur_page]
	match kind:
		event.PopupContentsCardInfo:
			if len(args) == 1:
				$PopUp/CardInfo.PopUp(args[0])
			else:
				$PopUp/CardInfo.PopUp(args[0], args[1])
		event.PopupContentsChestInfo:
			$PopUp/ChestInfo.PopUp(args[0], args[1])