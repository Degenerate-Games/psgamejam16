extends CharacterBody3D

@export var GRAVITY = -9.8
@export var TARGET_NODE: Node3D
@export var speed_component: SpeedComponent

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var MODE: int

var MODE_TRACKING = 0
var MODE_FOLLOWING = 1
var MODE_IDLE = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	if TARGET_NODE == null:
		MODE = MODE_FOLLOWING
	else:
		navigation_agent.target_position = TARGET_NODE.global_transform.origin
		MODE = MODE_TRACKING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if MODE == MODE_TRACKING:
		if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
			return
		var new_velocity = Vector3.ZERO
		if !navigation_agent.is_navigation_finished():
			if !navigation_agent.is_target_reachable():
				navigation_agent.target_position = TARGET_NODE.global_transform.origin
			var next_position = navigation_agent.get_next_path_position()
			var direction = next_position - global_transform.origin
			direction = direction.normalized()
			new_velocity = direction * speed_component.get_max_speed()
		if !is_on_floor():
			new_velocity.y = GRAVITY
		velocity = velocity.move_toward(new_velocity, 50 * delta)
		if velocity.length() > 0:
			var look_at_direction = velocity.normalized()
			look_at(global_transform.origin + look_at_direction)
		move_and_slide()
	elif MODE == MODE_FOLLOWING:
		TARGET_NODE = null
		velocity = Vector3.ZERO
		get_parent().progress_ratio += 0.001


func set_target(target: Node3D) -> void:
	TARGET_NODE = target
	navigation_agent.target_position = target.global_transform.origin
	MODE = MODE_TRACKING


func _on_navigation_agent_3d_navigation_finished():
	if MODE != MODE_TRACKING:
		return

	if TARGET_NODE.get_groups().find("enemy_base") != -1:
		TARGET_NODE.call_deferred("add_path_follower", self)
		MODE = MODE_FOLLOWING
