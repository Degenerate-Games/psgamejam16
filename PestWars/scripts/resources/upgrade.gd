class_name Upgrade
extends Resource

## The name of the upgrade.
@export var name: String
## The maximum level of the upgrade.
@export var max_level: int
## Whether to use advanced scaling for the upgrade. If checked the advanced_scaling array will be used. Otherwise, the level will be used as the scaling modifier.
@export var use_advanced_scaling: bool = false
## The advanced scaling array for the upgrade. The size of the array must be the same as the max level of the upgrade if use advanced scaling is checked.
@export var advanced_scaling: Array[float]

var current_level: int = 1


func _ready():
	if use_advanced_scaling:
		assert(advanced_scaling.size() == max_level, "Advanced scaling array must have the same size as the max level of the upgrade.")


func get_scaling() -> float:
	return get_scaling_at_level(current_level)


func get_scaling_at_level(level: int) -> float:
	if use_advanced_scaling:
		return advanced_scaling[level - 1]
	return level


func upgrade() -> bool:
	if current_level < max_level:
		current_level += 1
		return true
	return false
