extends VehicleBody3D

@export var MAX_STEERING = deg_to_rad(8)
@export var ENGINE_POWER = 50
@export var MAX_SPEED = 10

@export var TARGET_NODE: Node3D


@onready var animation_controller: AnimationPlayer = $AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# Called when the node enters the scene tree for the first time.
func _ready():
	navigation_agent.target_position = TARGET_NODE.global_transform.origin
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if !navigation_agent.is_navigation_finished():
		if !navigation_agent.is_target_reachable():
			navigation_agent.target_position = TARGET_NODE.global_transform.origin
		var next_position = navigation_agent.get_next_path_position()
		var direction = next_position - global_transform.origin
		direction = direction.normalized()
		var steering_angle = direction.angle_to(global_transform.basis.z)
		if steering_angle > PI / 2:
			steering_angle = steering_angle - PI
		steering_angle = clamp(steering_angle, -MAX_STEERING, MAX_STEERING)
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
