extends Resource
class_name BaseStrategy


@export var texture: Texture = null
@export var upgrade_text: String = ""


func apply_upgrade(_unit: PhysicsBody3D) -> void:
	pass