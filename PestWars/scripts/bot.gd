extends VehicleBody3D

const MODE_TRACKING = 0
const MODE_FOLLOWING = 1
const MODE_IDLE = 2

@export_group("Movement Settings")
@export_range(0, 70, 1, "radians_as_degrees") var max_steering_angle = deg_to_rad(8)
@export var engine_power = 50

@export_group("Navigation Settings")
@export var target_node: Node3D

@export_group("Components")
@export var hurtbox_component: HurtboxComponent
@export var speed_component: SpeedComponent

var current_mode: int

@onready var animation_controller: AnimationPlayer = $AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collider: CollisionShape3D = $CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if target_node == null:
		if get_parent() is PathFollow3D or get_parent() is SpawnerComponent:
			current_mode = MODE_FOLLOWING
			collider.disabled = true
		else:
			target_node = get_tree().get_first_node_in_group("base_controller").find_closest_base(global_transform.origin, "bot_base")
			navigation_agent.target_position = target_node.global_transform.origin
			collider.disabled = false
			current_mode = MODE_TRACKING
	else:
		navigation_agent.target_position = target_node.global_transform.origin
		collider.disabled = false
		current_mode = MODE_TRACKING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if current_mode == MODE_TRACKING:
		if target_node == null or !target_node.is_inside_tree():
			current_mode = MODE_IDLE
		elif !navigation_agent.is_navigation_finished():
			if !navigation_agent.is_target_reachable():
				navigation_agent.target_position = target_node.global_transform.origin
			var next_position = navigation_agent.get_next_path_position()
			var direction = next_position - global_transform.origin
			direction = direction.normalized()
			var steering_angle = signed_angle_between(direction, global_transform.basis.z, global_transform.basis.y)
			steering_angle = clamp(steering_angle, -max_steering_angle, max_steering_angle)
			steering = steering_angle

			engine_force = engine_power
			if linear_velocity.length() > speed_component.get_max_speed():
				engine_force = 0
			if engine_force > 0:
				animation_controller.play("bot_Moving")
			elif engine_force < 0:
				animation_controller.play_backwards("bot_Moving")
			else:
				animation_controller.pause()
		else:
			animation_controller.pause()
	elif current_mode == MODE_FOLLOWING:
		animation_controller.play("bot_Moving")
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		engine_force = 0
		steering = max_steering_angle
		get_parent().progress_ratio += 0.001
	else:
		animation_controller.pause()
		engine_force = 0
		steering = 0


func set_target(target: Node3D) -> void:
	target_node = target
	navigation_agent.target_position = target_node.global_transform.origin
	collider.disabled = false
	current_mode = MODE_TRACKING


func _on_navigation_agent_3d_navigation_finished():
	if target_node.get_groups().find("bot_base") != -1:
		target_node.call_deferred("add_path_follower", self)
		collider.disabled = true
		current_mode = MODE_FOLLOWING


func signed_angle_between(v1: Vector3, v2: Vector3, n: Vector3) -> float:
	var cross = v1.cross(v2)
	var unsigned_angle = atan2(cross.length(), v1.dot(v2))
	var s = cross.dot(n)
	if s < 0:
		return -unsigned_angle
	return unsigned_angle
