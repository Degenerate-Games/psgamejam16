class_name HitboxComponent
extends Area3D

@export var health_component: HealthComponent
var health: float


func damage(amount: float, attacker_team: String) -> void:
	if health_component:
		health_component.damage(amount, attacker_team)
