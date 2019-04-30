extends TextureProgress

func _ready():
	event.connect("BluePlayerInitialized", self, "init", [], CONNECT_ONESHOT)

func init(player):
	self.max_value = player.MAX_ENERGY
	event.connect("BlueEnergyUpdated", self, "updateEnergy")

func updateEnergy(energy):
	self.value = energy