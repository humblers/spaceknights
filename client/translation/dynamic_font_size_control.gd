extends Control

const MIN_SIZE = 28

var multiline = false
var org_font_size

func _ready():
	if self.get_class() == "Label":
		assert(self.get("clip_text") == true)
	var font = getFont()
	assert(font != null)
	org_font_size = font.size
	call_deferred("fontDownsizing")

func SetText(id):
	self.set("text", tr(id))
	var font = getFont()
	font.size = org_font_size
	call_deferred("fontDownsizing")

func fontDownsizing():
	var font = getFont()
	match self.get_class():
		"Label":
			while font.size > MIN_SIZE:
				var size = font.get_string_size(tr(self.get("text")))
				if size.x <= self.rect_size.x && size.y <= self.rect_size.y:
					break
				font.size -= 1
		"RichTextLabel":
			while font.size > MIN_SIZE:
				if self.call("get_content_height") < self.rect_size.y:
					break
				font.size -= 1
	font.update_changes()

func getFont():
	match self.get_class():
		"Label":
			return self.get_font("font")
		"RichTextLabel":
			return self.get_font("normal_font")
	return null