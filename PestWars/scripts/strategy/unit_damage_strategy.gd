extends BaseStrategy
class_name UnitDamageStrategy


@export_range(-100, 100, 1) var damage_multiplier: float = 1.0

func apply_upgrade(unit: PhysicsBody3D) -> void:
	if unit.has_node("HurtboxComponent"):
		var hurtbox: HurtboxComponent = unit.get_node("HurtboxComponent")
		hurtbox.set_damage_multiplier(damage_multiplier)