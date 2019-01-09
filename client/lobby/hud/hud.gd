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
export(NodePath) onready var cardupgrade_dialog = get_node(cardupgrade_dialog)
export(NodePath) onready var requesting_dialog = get_node(requesting_dialog)
export(NodePath) onready var error_dialog = get_node(error_dialog)
export(NodePath) onready var config_dialog = get_node(config_dialog)
export(NodePath) onready var chestinfo_dialog = get_node(chestinfo_dialog)
export(NodePath) onready var chestopen_dialog = get_node(chestopen_dialog)

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

func FormatStepToSecond(steps):
	var in_secs = float(steps) / data.StepPerSec
	return "%.*fs" % [1 if decimals(in_secs) > 0 else 0, in_secs]

func FormatPixelToTile(pixels):
	var in_tiles = float(pixels) / data.TileSizeInPixel
	return "%.*f" % [ 1 if decimals(in_tiles) > 0 else 0, in_tiles]

func FormatSpeed(speed):
	if speed > 150:
		return "Very Fast"
	if speed > 100:
		return "Fast"
	if speed > 75:
		return "Medium"
	if speed > 0:
		return "Slow"
	return null

func FormatAttackType(target_types, attack_type, damage_type):
	var types = PoolStringArray()
	if len(target_types) > 0 and not target_types.has(data.Squire):
		types.append("Siege")
	if attack_type == data.Bombing:
		types.append(data.Bombing)
	if damage_type == data.AntiShield:
		types.append("AB Attack")
	if len(types) == 0:
		return null
	if len(types) > 2:
		types.resize(2)
	return types.join(" & ")