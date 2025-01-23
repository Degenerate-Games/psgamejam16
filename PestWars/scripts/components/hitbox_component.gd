extends Area3D
class_name HitboxComponent


@export var health_component: HealthComponent
var health: float


func damage(amount: float) -> void:
	if health_component:
		health_component.damage(amount)


func _on_area_entered(area:Area3D) -> void:
	print("HitboxComponent: Area entered")
