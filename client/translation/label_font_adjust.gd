extends Label

const MIN_SIZE = 28

var cur_translated = ""

var org_label_size
var org_font_size

func _ready():
	var font = self.get_font("font")
	assert(font != null)
	org_label_size = self.rect_size
	org_font_size = font.size

func _process(delta):
	var translated = tr(self.text)
	if cur_translated == translated:
		return
	cur_translated = translated
	var font = self.get_font("font")
	font.size = org_font_size
	while font.size > MIN_SIZE:
		var size = font.get_string_size(translated)
		if self.autowrap:
			size.y *= self.get_line_count()
			size.x = self.rect_size.x
		if size.x <= org_label_size.x and size.y <= org_label_size.y:
			break
		font.size -= 1
		font.update_changes()