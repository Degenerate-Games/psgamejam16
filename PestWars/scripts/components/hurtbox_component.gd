extends Area3D
class_name HurtboxComponent


@export var base_damage: float = 1.0
@export var damage_multiplier: float = 1.0
@export var hits_allowed: int = 1
@export var damage_interval: float = 0.5

var can_damage: bool = true

@onready var damage_timer: Timer = $Timer


func _ready() -> void:
	damage_timer.wait_time = damage_interval


func set_damage_multiplier(multiplier: float) -> void:
	damage_multiplier = multiplier


func get_damage() -> float:
	return base_damage * damage_multiplier


func _on_area_entered(area:Area3D) -> void:
	if !can_damage:
		return

	if !(area is HitboxComponent):
		return
	
	area.damage(get_damage())
	hits_allowed -= 1
	if hits_allowed <= 0:
		get_parent().queue_free()
	else:
		can_damage = false
		damage_timer.start()


func _on_timer_timeout() -> void:
	can_damage = true
