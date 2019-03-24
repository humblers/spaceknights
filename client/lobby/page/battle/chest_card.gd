extends BaseButton

export(NodePath) onready var icon = get_node(icon)
export(NodePath) onready var frame = get_node(frame)
export(NodePath) onready var level_label = get_node(level_label)
export(NodePath) onready var holding_progress = get_node(holding_progress)
export(NodePath) onready var holding_label = get_node(holding_label)
export(NodePath) onready var card_name = get_node(card_name)
export(NodePath) onready var count = get_node(count)

var card

func Invalidate(card, count):
	self.card = card
	self.visible = card != null
	if card == null:
		return
	icon.texture = $CardIcon.get_resource(card.Name)
	frame.texture = get_card_frame(card.Type, card.Rarity)
	level_label.text = "%02d" % (card.Level + data.Upgrade.dict.RelativeLvByRarity[card.Rarity] + 1)
	var card_cost = data.Upgrade.CardCostNextLevel(card.Level)
	holding_progress.max_value = card_cost
	holding_progress.value = card.Holding
	holding_label.text = "%d/%d" % [card.Holding, card_cost]
	card_name.SetText("ID_%s" % card.Name.to_upper())
	self.count.text = "x%d" % count

func get_card_frame(type, rarity):
	var t = "squire"
	if type == data.KnightCard:
		t = "knight"
	return $CardFrame.get_resource("%s_%s_frame" % [t, rarity.to_lower()])