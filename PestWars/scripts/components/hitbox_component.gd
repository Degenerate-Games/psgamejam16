class_name HitboxComponent
extends Area3D

@export var health_component: HealthComponent
var health: float


func damage(amount: float) -> void:
	if health_component:
		health_component.damage(amount)
