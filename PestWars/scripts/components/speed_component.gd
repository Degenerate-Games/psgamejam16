class_name SpeedComponent
extends Node3D

@export var base_speed: float = 10.0
@export var speed_multiplier: float = 1.0


func set_speed_multiplier(multiplier: float) -> void:
	speed_multiplier = multiplier


func get_max_speed() -> float:
	return base_speed * speed_multiplier
