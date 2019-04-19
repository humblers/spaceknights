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
		increase_animation_player.rename_animation(anim_name, "%s-ref" % [anim_name])

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
	card_name.SetText("ID_%s" % card.Name.to_upper())
	self.count.text = "x%d" % count
	var holding_value = card.Holding - count
	holding_label.text = "%d/%d" % [card.Holding - count, card_cost]
	holding_progress.max_value = card_cost
	holding_progress.value = holding_value
	if card.Holding < card_cost:
		increase_anim_name = "increase"
	elif card.Holding - count < card_cost:
		increase_anim_name = "over"
	else:
		increase_anim_name = "full"
	var anim = increase_animation_player.get_animation("%s-ref" % [increase_anim_name]).duplicate()
	increase_animation_player.add_animation(increase_anim_name, anim)
	var basic_tracks = [
		"HoldingBar/UpgradeProgress/Inactive:visible",
		"HoldingBar/UpgradeProgress/Inactive:modulate",
		"HoldingBar/UpgradeProgress:self_modulate",
		"HoldingBar/UpgradeProgress/Active:emitting",
		"HoldingBar/UpgradeProgress/Active:visible",
	]
	for track in basic_tracks:
		var track_idx = anim.find_track(track)
		if track_idx < 0:
			continue
		var initial_val = anim.track_get_key_value(track_idx, 0)
		var split = track.split(":")
		get_node(split[0]).set(split[1], initial_val)
	var text_track_idx = anim.find_track("HoldingBar/Label:text")
	var value_track_idx = anim.find_track("HoldingBar/UpgradeProgress:value")
	var scale_track_idx = anim.find_track("HoldingBar:rect_scale")
	# this is strict restriction of these animations
	var key_num = anim.track_get_key_count(text_track_idx)
	assert(key_num == anim.track_get_key_count(value_track_idx))
	assert(key_num * 2 == anim.track_get_key_count(scale_track_idx))
	var upgrade_activated = holding_value >= card_cost
	for i in key_num:
		var prev_holding_value = holding_value
		if count > key_num:
			holding_value = round(holding_value + count * i / (key_num - 1))
		else:
			holding_value = min(card.Holding, holding_value + 1)
		anim.track_set_key_value(text_track_idx, i, "%d/%d" % [holding_value, card_cost])
		anim.track_set_key_value(value_track_idx, i, holding_value)
		anim.track_set_key_value(scale_track_idx, i * 2, Vector2(1 , 1))
		anim.track_set_key_value(scale_track_idx, i * 2 + 1,
				Vector2(1.1, 0.9) if prev_holding_value < holding_value else Vector2(1, 1))
		if not upgrade_activated and holding_value >= card_cost:
			var key_time = anim.track_get_key_time(text_track_idx, i)
			for track in basic_tracks:
				var track_idx = anim.find_track(track)
				anim.track_insert_key(track_idx, key_time,
					anim.track_get_key_value(track_idx, anim.track_get_key_count(track_idx) - 1))
			upgrade_activated = true

func get_card_frame(type, rarity):
	var t = "squire"
	if type == data.KnightCard:
		t = "knight"
	return $CardFrame.get_resource("%s_%s_frame" % [t, rarity.to_lower()])

func showIncrease():
	increase_animation_player.set_speed_scale(1.4)
	increase_animation_player.play(increase_anim_name)