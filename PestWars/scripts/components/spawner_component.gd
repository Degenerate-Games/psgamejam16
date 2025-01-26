extends Node3D
class_name SpawnerComponent

## The rate per second at which the spawner spawns objects. Not meant to be modified while the game is running.
@export var spawn_rate: float = 1.0
## The multiplier to apply to the spawn rate. This can be modified while the game is running.
@export var spawn_rate_multiplier: float = 1.0
## The scene to spawn when the spawner spawns an object.
@export var spawn_object: PackedScene

@onready var spawn_timer: Timer = $Timer

## Emitted when the spawner spawns an object.
signal object_spawned(object: Node3D)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer.wait_time = 1.0 / (spawn_rate * spawn_rate_multiplier)
	spawn_timer.start()


func _on_timer_timeout() -> void:
	var new_object = spawn_object.instantiate()
	add_child(new_object)
	object_spawned.emit(new_object)


func set_spawn_rate_multiplier(multiplier: float) -> void:
	spawn_rate_multiplier = multiplier
	var percentage_complete = spawn_timer.time_left / spawn_timer.wait_time
	var new_wait_time = 1.0 / (spawn_rate * spawn_rate_multiplier)
	spawn_timer.wait_time = new_wait_time * (1 - percentage_complete)
	if spawn_timer.is_stopped():
		spawn_timer.start()
