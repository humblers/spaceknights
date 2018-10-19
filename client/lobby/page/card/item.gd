extends BaseButton


func invalidate(name, page_card, disabled = false):
	self.name = name
	self.disabled = disabled
	self.modulate = Color(0.62, 0.62, 0.62, 0.62) if disabled else Color(1, 1, 1, 1)
	self.connect("button_up", page_card, "toggle_extra_btns", [self])
	$VBoxContainer/CardFrame/Icon.texture = resource.ICON[name]
	$VBoxContainer/CardFrame/VBoxContainer/Top/Energy/Label.text = "%d" % (stat.cards[name]["Cost"] / 1000)

func extra_btn_global_position():
	return $ExtraBtnPoint.global_position