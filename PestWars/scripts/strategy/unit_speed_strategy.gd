extends BaseStrategy
class_name UnitSpeedStrategy


@export_range(-100, 100, 1) var speed_multiplier: float = 1.0

func apply_upgrade(unit: PhysicsBody3D) -> void:
	if unit.get_groups().has("unit"):
		unit.set_speed_multiplier(speed_multiplier)