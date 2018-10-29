extends BaseButton

var name_

func invalidate(name, page_card, disabled = false):
	self.name_ = name
	self.disabled = disabled
	self.modulate = Color(0.62, 0.62, 0.62, 0.62) if disabled else Color(1, 1, 1, 1)
	self.connect("button_up", page_card, "toggle_extra_btns", [self])
	$VBoxContainer/CardFrame/Icon.texture = $ResourcePreloader.get_resource(name_)
	$VBoxContainer/CardFrame/VBoxContainer/Top/Energy/Label.text = "%d" % (stat.cards[name_]["Cost"] / 1000)

func extra_btn_global_position():
	return $ExtraBtnPoint.global_position