extends Area3D
class_name HurtboxComponent


@export var damage: float = 1.0
@export var damage_multiplier: float = 1.0
@export var hits_allowed: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_damage_multiplier(multiplier: float) -> void:
	damage_multiplier = multiplier


func _on_area_entered(area:Area3D) -> void:
	print("HurtboxComponent: Area entered")
	if area is HitboxComponent:
		area.damage(damage * damage_multiplier)
		hits_allowed -= 1
		if hits_allowed <= 0:
			get_parent().queue_free()
