extends Control

const MIN_SIZE = 28

var org_font_size
var downsize_processing = false
var downsize_booked = false

func _ready():
	var font = getFont()
	assert(font is DynamicFont)
	org_font_size = font.size
	match self.get_class():
		"Label":
			assert(self.get("clip_text") == true)
			self.add_font_override("font", font.duplicate())
			SetText()
		"RichTextLabel":
			self.set("bbcode_enabled", true)
			self.add_font_override("normal_font", font.duplicate())
			self.connect("visibility_changed", self, "SetText")
			SetText()

func SetText(id = null):
	match self.get_class():
		"Label":
			if id == null:
				id = self.get("text")
			var text = tr(id)
			self.set("text", text)
			var font = getFont()
			font.size = org_font_size
			while font.size > MIN_SIZE:
				var size = font.get_string_size(text)
				if size.x <= self.rect_size.x && size.y <= self.rect_size.y:
					break
				font.size -= 1
			font.update_changes()
		"RichTextLabel":
			if id == null:
				id = self.get("bbcode_text")
			self.set("bbcode_text", tr(id))
			if not visible:
				return
			if downsize_processing:
				downsize_booked = true
				return
			process()

func process():
	downsize_processing = true
	self.set("visible_characters", 0)
	var font = getFont()
	font.size = org_font_size
	while font.size > MIN_SIZE:
		yield(get_tree(), "idle_frame")
		if self.call("get_content_height") < self.rect_size.y:
			break
		font.size -= 1
	self.set("visible_characters", -1)
	if downsize_booked:
		downsize_booked = false
		process()
		return
	downsize_processing = false

func getFont():
	match self.get_class():
		"Label":
			return self.get_font("font")
		"RichTextLabel":
			return self.get_font("normal_font")
	return null