class_name HealthComponent
extends Node3D

signal can_heal
signal died

@export var base_health: float = 10.0
@export var health_multiplier: float = 1.0
@export var health_color: Color = Color(0, 0, 1, 1)
@export var base_heal_rate: float = 1.0
@export var heal_rate_multiplier: float = 1.0

var health: float

@onready var health_bar: TextureProgressBar = $SubViewport/TextureProgressBar
@onready var heal_timer: Timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = get_max_health()
	health_bar.tint_progress = health_color
	update_health_bar()
	heal_timer.wait_time = 1.0 / get_heal_rate()
	heal_timer.start()


func get_max_health() -> float:
	return base_health * health_multiplier


func get_heal_rate() -> float:
	return base_heal_rate * heal_rate_multiplier


func set_health_multiplier(multiplier: float) -> void:
	health_multiplier = multiplier
	update_health_bar()


func set_heal_rate_multiplier(multiplier: float) -> void:
	heal_rate_multiplier = multiplier
	var percentage_complete = heal_timer.time_left / heal_timer.wait_time
	var new_wait_time = 1.0 / get_heal_rate()
	heal_timer.wait_time = new_wait_time * (1 - percentage_complete)
	if heal_timer.is_stopped():
		heal_timer.start()


func is_hurt() -> bool:
	return health < get_max_health()


func heal(amount: float) -> void:
	health += amount
	if health > get_max_health():
		health = get_max_health()
	update_health_bar()


func damage(amount: float) -> void:
	health -= amount
	update_health_bar()
	if health <= 0:
		died.emit()


func update_health_bar() -> void:
	health_bar.max_value = get_max_health()
	health_bar.value = health


func _on_timer_timeout() -> void:
	can_heal.emit()
