extends Player

export(NodePath) onready var mothership = get_node(mothership)
export(NodePath) onready var tile = get_node(tile)
export(NodePath) onready var energy_ui = get_node(energy_ui) if energy_ui else null
export(NodePath) onready var unit_ready_sound = get_node(unit_ready_sound) if unit_ready_sound else null

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

func addKnights(knights):
	.addKnights(knights)
	for i in len(knightIds):
		var id = knightIds[i]
		var knight = game.FindUnit(id)
		if i == 0:
			knight.side = stat.Center
		elif i == 1:
			knight.side = stat.Left
		else:
			knight.side = stat.Right
			
		# make invisible to play show animation
		knight.visible = false

func Update():
	.Update()
	if energy_ui:
		energy_ui.value = energy

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
	mothership.destroy(knight.side)
	expand_spawnable_area(knight)

func OnKnightHalfDamaged(knight):
	mothership.partial_destroy(knight.side)

func expand_spawnable_area(knight):
	if knight.side == "Center":
		return
	var s = knight.side
	tile.OnKnightDead(color, s)