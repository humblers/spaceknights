extends CanvasLayer

export(NodePath) onready var lobby = get_node(lobby)

export(NodePath) onready var bot = get_node(bot)

export(NodePath) onready var page_battle_btn = get_node(page_battle_btn)
export(NodePath) onready var page_card_btn = get_node(page_card_btn)
export(NodePath) onready var page_explore_btn = get_node(page_explore_btn)
export(NodePath) onready var page_shop_btn = get_node(page_shop_btn)
export(NodePath) onready var page_social_btn = get_node(page_social_btn)

export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var exp_label = get_node(exp_label)
export(NodePath) onready var galacticoin_label = get_node(galacticoin_label)
export(NodePath) onready var dimensium_label = get_node(dimensium_label)

export(NodePath) onready var cardinfo_dialog = get_node(cardinfo_dialog)
export(NodePath) onready var requesting_dialog = get_node(requesting_dialog)
export(NodePath) onready var error_dialog = get_node(error_dialog)
export(NodePath) onready var config_dialog = get_node(config_dialog)

func _ready():
	for page in lobby.PAGES:
		var btn = get("page_%s_btn" % page.to_lower())
		btn.connect("button_up", self, "page_select", [page])

func invalidate():
	static_func.set_text(level_label, "%d" % (user.Level + 1))
	static_func
	exp_label.text = "%d/xxx" % user.Exp
	galacticoin_label.text = "%d" % user.Galacticoin
	dimensium_label.text = "%d" % user.Dimensium

func page_select(page):
	lobby.input_manager.move_to_page(page)