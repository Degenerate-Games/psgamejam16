extends BaseStrategy
class_name SpawnSpeedStrategy


@export_range(-100, 100, 1) var speed_multiplier: float = 1.0

func apply_upgrade(unit: PhysicsBody3D) -> void:
	if unit.get_groups().has("spawner"):
		unit.set_spawn_speed_multiplier(speed_multiplier)