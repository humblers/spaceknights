extends BaseButton

var name_

onready var base = $ItemBase

func _ready():
	self.connect("button_down", self, "down")
	self.connect("button_up", self, "up")

func invalidate(name, page_card, disabled = false):
	self.name_ = name
	if not self.is_connected("button_up", page_card, "set_pressed_card"):
		self.connect("button_up", page_card, "set_pressed_card", [self])
	if name != null:
		self.disabled = disabled
		self.modulate = Color(0.62, 0.62, 0.62, 0.62) if disabled else Color(1, 1, 1, 1)
		base.get_node("CardFrame/Icon").texture = base.get_node("Icon").get_resource(name_)
		base.get_node("CardFrame/Frame").texture = base.get_node("Frame").get_resource(stat.cards[name_]["Rarity"])
		base.get_node("CardFrame/Control/Energy/Label").text = "%d" % (stat.cards[name_]["Cost"] / 1000)

func down():
	base.get_node("AnimationPlayer").play("down")

func up():
	base.get_node("AnimationPlayer").play_backwards("down")