extends CharacterBody3D

@export var MAX_SPEED = 10
@export var GRAVITY = -9.8
@export var TARGET_NODE: Node3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var damage_multiplier: float = 1.0
var speed_multiplier: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	navigation_agent.target_position = TARGET_NODE.global_transform.origin
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	var new_velocity = Vector3.ZERO
	if !navigation_agent.is_navigation_finished():
		if !navigation_agent.is_target_reachable():
			navigation_agent.target_position = TARGET_NODE.global_transform.origin
		var next_position = navigation_agent.get_next_path_position()
		var direction = next_position - global_transform.origin
		direction = direction.normalized()
		new_velocity = direction * MAX_SPEED * speed_multiplier
	if !is_on_floor():
		new_velocity.y = GRAVITY
	velocity = velocity.move_toward(new_velocity, 10 * delta)
	if velocity.length() > 0:
		var look_at_direction = velocity.normalized()
		look_at(global_transform.origin + look_at_direction)
	move_and_slide()


func _on_navigation_agent_3d_navigation_finished():
	pass


func set_damage_multiplier(multiplier: float) -> void:
	damage_multiplier = multiplier


func set_speed_multiplier(multiplier: float) -> void:
	speed_multiplier = multiplier
