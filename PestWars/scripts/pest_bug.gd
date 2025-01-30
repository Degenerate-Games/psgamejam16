extends CharacterBody3D

const MODE_TRACKING = 0
const MODE_FOLLOWING = 1
const MODE_IDLE = 2

@export var gravity = -9.8
@export var target_node: Node3D
@export var speed_component: SpeedComponent
@export var hurtbox_component: HurtboxComponent

var current_mode: int

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collider: CollisionShape3D = $CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if target_node == null:
		if get_parent() is PathFollow3D or get_parent() is SpawnerComponent:
			disable_collision()
			current_mode = MODE_FOLLOWING
		else:
			target_node = get_tree().get_first_node_in_group("base_controller").find_closest_base(global_transform.origin, "enemy_base")
			navigation_agent.target_position = target_node.global_transform.origin
			enable_collision()
			current_mode = MODE_TRACKING
	else:
		navigation_agent.target_position = target_node.global_transform.origin
		enable_collision()
		current_mode = MODE_TRACKING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if current_mode == MODE_TRACKING:
		if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
			return
		var new_velocity = Vector3.ZERO
		if !navigation_agent.is_navigation_finished():
			if !navigation_agent.is_target_reachable():
				navigation_agent.target_position = target_node.global_transform.origin
			var next_position = navigation_agent.get_next_path_position()
			var direction = next_position - global_transform.origin
			direction = direction.normalized()
			new_velocity = direction * speed_component.get_max_speed()
		if !is_on_floor():
			new_velocity.y = gravity
		velocity = velocity.move_toward(new_velocity, 50 * delta)
		if velocity.length() > 0:
			var look_at_direction = velocity.normalized()
			look_at(global_transform.origin + look_at_direction)
		move_and_slide()
	elif current_mode == MODE_FOLLOWING:
		target_node = null
		velocity = Vector3.ZERO
		get_parent().progress_ratio += 0.001


func disable_collision() -> void:
	for i in range(get_child_count()):
		var child = get_child(i)
		if child is CollisionShape3D:
			child.disabled = true


func enable_collision() -> void:
	for i in range(get_child_count()):
		var child = get_child(i)
		if child is CollisionShape3D:
			child.disabled = false


func set_target(target: Node3D) -> void:
	target_node = target
	navigation_agent.target_position = target.global_transform.origin
	enable_collision()
	current_mode = MODE_TRACKING


func _on_navigation_agent_3d_navigation_finished():
	if current_mode != MODE_TRACKING:
		return

	if target_node.get_groups().find("enemy_base") != -1:
		target_node.call_deferred("add_path_follower", self)
		disable_collision()
		current_mode = MODE_FOLLOWING
