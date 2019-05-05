extends Control

export(NodePath) onready var page_battle_btn = get_node(page_battle_btn)
export(NodePath) onready var page_card_btn = get_node(page_card_btn)
export(NodePath) onready var page_explore_btn = get_node(page_explore_btn)
export(NodePath) onready var page_shop_btn = get_node(page_shop_btn)
export(NodePath) onready var page_social_btn = get_node(page_social_btn)

export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var exp_label = get_node(exp_label)
export(NodePath) onready var galacticoin_label = get_node(galacticoin_label)
export(NodePath) onready var dimensium_label = get_node(dimensium_label)

func _ready():
	for page in event.Pages:
		var btn = get("page_%s_btn" % page.to_lower())
		btn.connect("button_up", self, "pageSelect", [page])
	event.connect("InvalidateHUD", self, "invalidate")

func invalidate():
	level_label.text = "%d" % (user.Level + 1)
	exp_label.text = "%d/xxx" % user.Exp
	galacticoin_label.text = "%d" % user.Galacticoin
	dimensium_label.text = "%d" % user.Dimensium

func pageSelect(page):
	event.emit_signal("PageSelected", page)