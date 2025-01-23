extends Node3D
class_name HealthComponent

@export var MAX_HEALTH: float = 10.0
@export var health_color: Color = Color(0, 0, 1, 1)
var health: float

@onready var health_bar: TextureProgressBar = $SubViewport/TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH
	health_bar.value = 100
	health_bar.tint_progress = health_color


func damage(amount: float) -> void:
	health -= amount
	health_bar.value = health / MAX_HEALTH * 100
	if health <= 0:
		get_parent().queue_free()
