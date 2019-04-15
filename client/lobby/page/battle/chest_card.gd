extends BaseButton

export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var holding_progress = get_node(holding_progress)
export(NodePath) onready var holding_label = get_node(holding_label)
export(NodePath) onready var card_name = get_node(card_name)
export(NodePath) onready var count = get_node(count)
export(NodePath) onready var upgrade_animation_player = get_node(upgrade_animation_player)

var card
var anim
#var card_holding
var card_count
var card_cost

func Invalidate(card, count):
	self.card = card
	self.visible = card != null
	if card == null:
		return
	icon.texture = $CardIcon.get_resource(card.Name)
	frame.texture = get_card_frame(card.Type, card.Rarity)
	level_label.text = "%02d" % (card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity] + 1)
	card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	
	card_name.SetText("ID_%s" % card.Name.to_upper())
	self.count.text = "x%d" % count
	card_count = count

func get_card_frame(type, rarity):
	var t = "squire"
	if type == data.KnightCard:
		t = "knight"
	return $CardFrame.get_resource("%s_%s_frame" % [t, rarity.to_lower()])
	
func show_increase():
	if card.Holding < card_cost:
		var dup = upgrade_animation_player.get_animation("increase").duplicate()
		upgrade_animation_player.rename_animation("increase", "increase-ref")
		upgrade_animation_player.add_animation("increase", dup)
		anim = dup
		var value_path = "HoldingBar/UpgradeProgress:value"
		var value_track_idx = anim.find_track(value_path)
		var key_num = anim.track_get_key_count(value_track_idx)
		var text_path = "HoldingBar/Label:text"
		var text_track_idx = anim.find_track(text_path)
		var scale_path = "HoldingBar:rect_scale"
		var scale_track_idx = anim.find_track(scale_path)
		holding_progress.max_value = card_cost
		for i in key_num:
			var newvalue = round(card.Holding - card_count + card_count * (i+1)/10)
			anim.track_set_key_value(value_track_idx, i, newvalue)
			var newtext = "%d/%d" % [newvalue, card_cost]
			anim.track_set_key_value(text_track_idx, i, newtext)
			if newvalue ==  round(card.Holding - card_count + card_count * i/10):
				anim.track_set_key_value(scale_track_idx, i*2, Vector2(1,1))
			elif i!=key_num-1:
				anim.track_set_key_value(scale_track_idx, i*2, Vector2(1.1,0.9))
		upgrade_animation_player.play("increase")
		yield(upgrade_animation_player, "animation_finished")
		holding_progress.max_value = card_cost
		holding_progress.value = card.Holding
		holding_label.text = "%d/%d" % [card.Holding, card_cost]
	elif card.Holding - card_count < card_cost:
		var dup = upgrade_animation_player.get_animation("over").duplicate()
		upgrade_animation_player.rename_animation("over", "over-ref")
		upgrade_animation_player.add_animation("over", dup)
		anim = dup
		var value_path = "HoldingBar/UpgradeProgress:value"
		var value_track_idx = anim.find_track(value_path)
		var key_num = anim.track_get_key_count(value_track_idx)
		var text_path = "HoldingBar/Label:text"
		var text_track_idx = anim.find_track(text_path)
		var scale_path = "HoldingBar:rect_scale"
		var scale_track_idx = anim.find_track(scale_path)
		holding_progress.max_value = card_cost
		for i in key_num:
			var newvalue = round(card.Holding - card_count + card_count * (i+1)/10)
			anim.track_set_key_value(value_track_idx, i, newvalue)
			var newtext = "%d/%d" % [newvalue, card_cost]
			anim.track_set_key_value(text_track_idx, i, newtext)
			if newvalue ==  round(card.Holding - card_count + card_count * i/10):
				anim.track_set_key_value(scale_track_idx, i*2, Vector2(1,1))
			elif i!=key_num-1:
				anim.track_set_key_value(scale_track_idx, i*2, Vector2(1.1,0.9))
		upgrade_animation_player.play("over")
		yield(upgrade_animation_player, "animation_finished")
		holding_progress.max_value = card_cost
		holding_progress.value = card.Holding
		holding_label.text = "%d/%d" % [card.Holding, card_cost]
	else :
		var dup = upgrade_animation_player.get_animation("full").duplicate()
		upgrade_animation_player.rename_animation("full", "full-ref")
		upgrade_animation_player.add_animation("full", dup)
		anim = dup
		var text_path = "HoldingBar/Label:text"
		var text_track_idx = anim.find_track(text_path)
		var key_num = anim.track_get_key_count(text_track_idx)
		var scale_path = "HoldingBar:rect_scale"
		var scale_track_idx = anim.find_track(scale_path)
		for i in key_num:
			var newvalue = round(card.Holding - card_count + card_count * (i+1)/10)
			var newtext = "%d/%d" % [newvalue, card_cost]
			anim.track_set_key_value(text_track_idx, i, newtext)
			if newvalue ==  round(card.Holding - card_count + card_count * i/10):
				anim.track_set_key_value(scale_track_idx, i*2, Vector2(1,1))
			elif i!=key_num-1:
				anim.track_set_key_value(scale_track_idx, i*2, Vector2(1.1,0.9))
		upgrade_animation_player.play("full")
		yield(upgrade_animation_player, "animation_finished")
		holding_progress.max_value = card_cost
		holding_progress.value = card.Holding
		holding_label.text = "%d/%d" % [card.Holding, card_cost]
