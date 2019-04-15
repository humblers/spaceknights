extends BaseButton

export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var holding_progress = get_node(holding_progress)
export(NodePath) onready var holding_label = get_node(holding_label)
export(NodePath) onready var card_name = get_node(card_name)
export(NodePath) onready var count = get_node(count)
export(NodePath) onready var increase_animation_player = get_node(increase_animation_player)

var card
var increase_anim_name

func _ready():
	for anim_name in ["increase", "over", "full"]:
		var dup = increase_animation_player.get_animation(anim_name).duplicate()
		increase_animation_player.remove_animation(anim_name)
		increase_animation_player.add_animation(anim_name, dup)

func Invalidate(card, count):
	self.card = card
	self.visible = card != null
	if card == null:
		increase_anim_name = null
		return
	icon.texture = $CardIcon.get_resource(card.Name)
	frame.texture = get_card_frame(card.Type, card.Rarity)
	level_label.text = "%02d" % (card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity] + 1)
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	holding_progress.max_value = card_cost
	holding_progress.value = card.Holding - count
	if card.Holding < card_cost:
		increase_anim_name = "increase"
	elif card.Holding - count < card_cost:
		increase_anim_name = "over"
	else:
		increase_anim_name = "full"
	var anim = increase_animation_player.get_animation(increase_anim_name)
	var text_path = "HoldingBar/Label:text"
	var text_track_idx = anim.find_track(text_path)
	var key_num = anim.track_get_key_count(text_track_idx)
	var value_path = "HoldingBar/UpgradeProgress:value"
	var value_track_idx = anim.find_track(value_path)
	var scale_path = "HoldingBar:rect_scale"
	var scale_track_idx = anim.find_track(scale_path)
	var prev_holding_value = -1
	for i in key_num:
		var holding_value = round(card.Holding - count + count * i / (key_num - 1))
		if increase_anim_name in ["increase", "over"]:
			anim.track_set_key_value(value_track_idx, i, holding_value)
		anim.track_set_key_value(text_track_idx, i, "%d/%d" % [holding_value, card_cost])
		var scale_vec = Vector2(1, 1)
		if prev_holding_value != holding_value and i != key_num - 1:
			scale_vec = Vector2(1.1, 0.9)
		anim.track_set_key_value(scale_track_idx, i*2, scale_vec)
		prev_holding_value = holding_value

func get_card_frame(type, rarity):
	var t = "squire"
	if type == data.KnightCard:
		t = "knight"
	return $CardFrame.get_resource("%s_%s_frame" % [t, rarity.to_lower()])

func showIncrease():
	increase_animation_player.play(increase_anim_name)