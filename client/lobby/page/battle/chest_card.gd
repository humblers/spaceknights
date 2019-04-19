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
	card_name.SetText("ID_%s" % card.Name.to_upper())
	self.count.text = "x%d" % count
	holding_label.text = "%d/%d" % [card.Holding - count, card_cost]
	holding_progress.max_value = card_cost
	holding_progress.value = card.Holding - count
	if card.Holding < card_cost:
		increase_anim_name = "increase"
		holding_progress.set_self_modulate(Color(0.101, 0.584, 1, 1))
		holding_progress.get_node("Active").hide()
		holding_progress.get_node("Active").set_emitting(false)
		holding_progress.get_node("Inactive").show()
	elif card.Holding - count < card_cost:
		increase_anim_name = "over"
		holding_progress.set_self_modulate(Color(0.101, 0.584, 1, 1))
		holding_progress.get_node("Active").hide()
		holding_progress.get_node("Active").set_emitting(false)
		holding_progress.get_node("Inactive").show()
	else:
		increase_anim_name = "full"
		holding_progress.set_self_modulate(Color(0, 1, 0.553,1))
		holding_progress.get_node("Active").show()
		holding_progress.get_node("Active").set_emitting(true)
		holding_progress.get_node("Inactive").hide()
	var anim = increase_animation_player.get_animation(increase_anim_name)
	var text_path = "HoldingBar/Label:text"
	var text_track_idx = anim.find_track(text_path)
	var value_path = "HoldingBar/UpgradeProgress:value"
	var value_track_idx = anim.find_track(value_path)
	var scale_path = "HoldingBar:rect_scale"
	var scale_track_idx = anim.find_track(scale_path)
	var counter = 11
	if count < counter:
		counter = count + 1
	for i in anim.track_get_key_count(value_track_idx):
		anim.track_remove_key(value_track_idx, 0)
	for i in anim.track_get_key_count(text_track_idx):
		anim.track_remove_key(text_track_idx, 0)
	for i in anim.track_get_key_count(scale_track_idx):
		anim.track_remove_key(scale_track_idx, 0 )
	var newkeytime = -1.0
	for i in counter:
		var holding_value
		if count > 11:
			holding_value = round(card.Holding - count + count * i / (counter - 1))
		else:
			holding_value = card.Holding - count + i
		if increase_anim_name in ["increase", "over"]:
			anim.track_insert_key(value_track_idx, float(i) / 5.0, holding_value)
		anim.track_insert_key(text_track_idx, float(i) / 5.0, "%d/%d" % [holding_value, card_cost])
		var scale_vec = Vector2(1.1, 0.9)
		anim.track_insert_key(scale_track_idx, (((float(i) * 2.0) + 1.0) / 10.0) , scale_vec)
		scale_vec = Vector2(1 , 1)
		anim.track_insert_key(scale_track_idx, ((float(i) * 2.0) / 10.0) , scale_vec)
		if increase_anim_name == "over" && newkeytime < 0 && holding_value >= card_cost:
			var arrow_path = "HoldingBar/UpgradeProgress/Inactive:visible"
			var arrow_track_idx = anim.find_track(arrow_path)
			var arrow_modul_path = "HoldingBar/UpgradeProgress/Inactive:modulate"
			var arrow_modul_track_idx = anim.find_track(arrow_modul_path)
			var bar_modul_path = "HoldingBar/UpgradeProgress:self_modulate"
			var bar_modu_track_idx = anim.find_track(bar_modul_path)
			var up_emit_path = "HoldingBar/UpgradeProgress/Active:emitting"
			var up_emit_track_idx = anim.find_track(up_emit_path)
			var up_visi_path = "HoldingBar/UpgradeProgress/Active:visible"
			var up_visi_track_idx = anim.find_track(up_visi_path)
			newkeytime = float(i) / 5.0
			anim.track_remove_key(arrow_track_idx, 1)
			anim.track_remove_key(arrow_modul_track_idx, 1)
			anim.track_remove_key(bar_modu_track_idx, 1)
			anim.track_remove_key(up_emit_track_idx, 1)
			anim.track_remove_key(up_visi_track_idx, 1)
			anim.track_insert_key(arrow_track_idx, newkeytime, false)
			anim.track_insert_key(arrow_modul_track_idx, newkeytime, Color(0, 0.5, 1, 0))
			anim.track_insert_key(bar_modu_track_idx, newkeytime, Color(0, 1, 0.553,1))
			anim.track_insert_key(up_emit_track_idx, newkeytime, true)
			anim.track_insert_key(up_visi_track_idx, newkeytime, true)
	anim.track_remove_key(scale_track_idx, counter * 2 - 1 )
func get_card_frame(type, rarity):
	var t = "squire"
	if type == data.KnightCard:
		t = "knight"
	return $CardFrame.get_resource("%s_%s_frame" % [t, rarity.to_lower()])

func showIncrease():
	increase_animation_player.set_speed_scale(1.4)
	increase_animation_player.play(increase_anim_name)