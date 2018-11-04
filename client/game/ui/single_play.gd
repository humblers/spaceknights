extends Control

onready var player = get_node("../../Players/Blue")

var pending = {}

func _ready():
	$Energy.max_value = player.MAX_ENERGY
	for i in range(player.HAND_SIZE):
		var card = $Cards.get_node("Hand%s" % (i + 1))
		card.connect("gui_input", self, "_handle_input")
	
func _process(delta):
	$Energy.value = player.energy
	$Cards/Next.Set(player.pending[0].Name, player.rollingCounter <= 0)
	for i in range(player.HAND_SIZE):
		var name = player.hand[i].Name
		var card = $Cards.get_node("Hand%s" % (i+1))
		var unit_pos = get_node("../../Hand/Card%s" % (i+1))
		if pending.has(i):
			if name == pending[i]:
				card.Set(null)
			else:
				pending.erase(i)
				card.Set(name, player.energy)
		else:
			if name == "":
				card.Set(null)
			else:
				card.Set(name, player.energy)

func _handle_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			pass
	if event is InputEventMouseMotion:
			pass

func update_card(i, name, energy):
	var icon = $Cards.get_node("Hand%s" % (i+1))
	var dummy = get_node("../../DummyUnits/Card%s" % (i+1))

