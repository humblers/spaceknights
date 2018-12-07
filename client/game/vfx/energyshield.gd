extends Node2D

func hit(attacker):
	var angle = attacker.global_position.angle_to_point(self.global_position)
	self.global_rotation = PI/2 + angle
	$EnergyShieldAni.play("energyshield")
