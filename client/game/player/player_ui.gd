extends Player

export(NodePath) onready var mothership = get_node(mothership)
export(NodePath) onready var tile = get_node(tile)
export(NodePath) onready var energy_ui = get_node(energy_ui) if energy_ui else null
export(NodePath) onready var unit_ready_sound = get_node(unit_ready_sound) if unit_ready_sound else null

export(NodePath) onready var hand1 = get_node(hand1) if hand1 else null
export(NodePath) onready var hand2 = get_node(hand2) if hand2 else null
export(NodePath) onready var hand3 = get_node(hand3) if hand3 else null
export(NodePath) onready var hand4 = get_node(hand4) if hand4 else null
export(NodePath) onready var next = get_node(next) if next else null
export(NodePath) onready var skill_left = get_node(skill_left) if skill_left else null
export(NodePath) onready var skill_right = get_node(skill_right) if skill_right else null

var id
var color

func Init(playerData, game):
	.Init(playerData, game)
	id = playerData.Id
	color = team
	if game.team_swapped:
		color = "Blue" if team == "Red" else "Red"
	if energy_ui:
		energy_ui.max_value = MAX_ENERGY
	set_deck_ui()
	mothership.Init(self)

func set_deck_ui():
	for i in len(hand):
		var node = get("hand%d" % (i+1))
		if node != null:
			node.Set(hand[i])
	if next != null:
		next.Set(pending[0])

func addKnight(name, level, side):
	var knight = .addKnight(name, level, side)
	knight.side = side
	# make invisible to play show animation
	knight.visible = false

func Update():
	.Update()
	if energy_ui:
		energy_ui.value = energy
	for i in HAND_SIZE:
		var node = get("hand%d" % (i+1))
		if node != null:
			node.Update(energy)
	if next != null:
		next.Update(drawCounter <= 0)

func useCard(c, tileX, tileY):
	.useCard(c, tileX, tileY)
	if unit_ready_sound:
		var d = stat.cards[c.Name]
		var name = d.Unit
		var u = stat.units[name]
		var k = findKnight(name)
		var isKnight = u["type"] == stat.Knight
		if not isKnight:
			var sound = unit_ready_sound.get_resource(c.Name)
			$AudioStreamPlayer.stream = sound
			$AudioStreamPlayer.play()

func OnKnightDead(knight):
	.OnKnightDead(knight)
	mothership.Destroy(knight.side)
	tile.Expand(color, knight.side)

func OnKnightHalfDamaged(knight):
	mothership.PartialDestroy(knight.side)
