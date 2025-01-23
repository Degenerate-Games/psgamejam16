extends VehicleBody3D

@export_category("Movement Settings")
@export_range(0, 70, 1, "radians_as_degrees") var MAX_STEERING_ANGLE = deg_to_rad(8)
@export var ENGINE_POWER = 50
@export var MAX_SPEED = 10

@export_category("Navigation Settings")
@export var TARGET_NODE: Node3D

var old_parent: Node3D

var MODE: int

var MODE_TRACKING = 0
var MODE_FOLLOWING = 1
var MODE_IDLE = 2



@onready var animation_controller: AnimationPlayer = $AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if TARGET_NODE == null:
		MODE = MODE_FOLLOWING
	else:
		navigation_agent.target_position = TARGET_NODE.global_transform.origin
		MODE = MODE_TRACKING
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if MODE == MODE_TRACKING:
		if !navigation_agent.is_navigation_finished():
			if !navigation_agent.is_target_reachable():
				navigation_agent.target_position = TARGET_NODE.global_transform.origin
			var next_position = navigation_agent.get_next_path_position()
			var direction = next_position - global_transform.origin
			direction = direction.normalized()
			var steering_angle = signed_angle_between(direction, global_transform.basis.z, global_transform.basis.y)
			steering_angle = clamp(steering_angle, -MAX_STEERING_ANGLE, MAX_STEERING_ANGLE)
			steering = steering_angle
			
			engine_force = ENGINE_POWER
			if linear_velocity.length() > MAX_SPEED:
				engine_force = 0
			if engine_force > 0:
				animation_controller.play("bot_Moving")
			elif engine_force < 0:
				animation_controller.play_backwards("bot_Moving")
			else:
				animation_controller.pause()
		else:
			animation_controller.pause()
	elif MODE == MODE_FOLLOWING:
		animation_controller.play("bot_Moving")
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		engine_force = 0
		steering = MAX_STEERING_ANGLE
		get_parent().progress_ratio += 0.001
	else:
		animation_controller.pause()
		engine_force = 0
		steering = 0


func _on_navigation_agent_3d_navigation_finished():
	# Target is not a friendly base
	if TARGET_NODE.get_groups().find("friendly_base") == -1:
		queue_free()
	else:
		old_parent = get_parent()
		TARGET_NODE.call_deferred("add_path_follower", self)
		MODE = MODE_FOLLOWING


func signed_angle_between(v1: Vector3, v2: Vector3, n: Vector3) -> float:
	var cross = v1.cross(v2)
	var unsigned_angle = atan2(cross.length(), v1.dot(v2))
	var s = cross.dot(n)
	if s < 0:
		return -unsigned_angle
	return unsigned_angle