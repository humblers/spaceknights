extends BaseButton

export(NodePath) onready var page_card = get_node(page_card)
export(NodePath) onready var base = get_node(base)
export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var cost = get_node(cost)
export(NodePath) onready var pressed_btn_guide = get_node(pressed_btn_guide)

export(NodePath) onready var base_animation_player = get_node(base_animation_player)
export(NodePath) onready var animation_player = get_node(animation_player)

var name_

func _ready():
	self.connect("button_down", self, "down")
	self.connect("button_up", self, "up")
	self.connect("button_up", page_card, "set_pressed_card", [self])

func invalidate(name):
	self.name_ = name
	self.visible = name != null
	if name == null:
		return
	var data = stat.cards[name_]
	icon.texture = page_card.lobby.resource_manager.get_card_icon(name_)
	frame.texture = page_card.lobby.resource_manager.get_card_frame(data.Type, data.Rarity)
	cost.text = "%d" % (data.Cost / 1000)

func down():
	base_animation_player.play("down")

func up():
	base_animation_player.play_backwards("down")

func changed():
	animation_player.play("changed")

func get_pressed_btn_guide():
	return pressed_btn_guide