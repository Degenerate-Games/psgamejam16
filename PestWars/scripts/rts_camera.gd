extends Node3D


@export_group("Camera Movement Settings")
@export_range(0, 100, 1) var camera_move_speed: float = 20.0
@export_range(0, 32, 4) var camera_automatic_pan_margin: int = 16
@export_range(0, 20, 0.5) var camera_pan_speed: float = 12.0

@export_group("Camera Zoom Settings")
@export_range(0, 100, 1) var camera_zoom_speed: float = 40.0
@export_range(0, 100, 1) var camera_zoom_min: float = 10.0
@export_range(0, 100, 1) var camera_zoom_max: float = 25.0
@export_range(0, 2, 0.1) var camera_zoom_dampener: float = 0.9

@export_group("Camera Rotation Settings")
@export_range(0, TAU, 0.1) var camera_rotation_speed: float = PI / 4
@export_range(0, 2, 0.1) var camera_rotation_dampener: float = 0.9
@export_range(-TAU, TAU, 0.1) var camera_socket_rotation_min: float = -PI / 2
@export_range(-TAU, TAU, 0.1) var camera_socket_rotation_max: float = PI / 2
@export_range(0, 1, 0.1) var camera_mouse_rotation_speed_scale: float = 0.3

@export_group("Camera Movement Flags")
@export var camera_can_process: bool = true
@export var camera_can_move_base: bool = true
@export var camera_can_zoom: bool = true
@export var camera_can_automatic_pan: bool = true
@export var camera_can_rotate_base: bool = true
@export var camera_can_rotate_socket: bool = true
@export var camera_can_rotate_with_mouse: bool = true

var camera_zoom_direction: float = 0.0
var camera_rotation_direction: float = 0.0
var camera_rotating_with_mouse: bool = false
var mouse_last_position: Vector2 = Vector2.ZERO

@onready var camera_socket = $CameraSocket
@onready var camera = $CameraSocket/Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !camera_can_process: return

	camera_base_move(delta)
	camera_base_rotate_update(delta)
	camera_zoom_update(delta)
	camera_automatic_pan(delta)
	camera_rotate_to_offset(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("camera_zoom_in"):
		camera_zoom_direction = -1.0
	elif event.is_action("camera_zoom_out"):
		camera_zoom_direction = 1.0
	
	if event.is_action("camera_rotate_left"):
		camera_rotation_direction = 1.0
	elif event.is_action("camera_rotate_right"):
		camera_rotation_direction = -1.0
	
	if event.is_action_pressed("camera_rotate"):
		mouse_last_position = get_viewport().get_mouse_position()
		camera_rotating_with_mouse = true
	elif event.is_action_released("camera_rotate"):
		camera_rotating_with_mouse = false


func camera_base_move(delta: float) -> void:
	if !camera_can_move_base: return
	var direction: Vector3 = Vector3.ZERO

	if Input.is_action_pressed("camera_forward"): direction -= transform.basis.z
	if Input.is_action_pressed("camera_backward"): direction += transform.basis.z
	if Input.is_action_pressed("camera_right"): direction += transform.basis.x
	if Input.is_action_pressed("camera_left"): direction -= transform.basis.x

	position += direction.normalized() * camera_move_speed * delta


func camera_zoom_update(delta: float) -> void:
	if !camera_can_zoom: return
	
	var new_zoom: float = camera.position.z + camera_zoom_direction * camera_zoom_speed * delta
	new_zoom = clamp(new_zoom, camera_zoom_min, camera_zoom_max)
	camera.position.z = new_zoom

	camera_zoom_direction *= camera_zoom_dampener


func camera_automatic_pan(delta: float) -> void:
	if !camera_can_automatic_pan: return

	var viewport_current = get_viewport()
	var pan_direction = Vector2(-1, -1)
	var viewports_visible_rect = Rect2i(viewport_current.get_visible_rect())
	var viewport_size = viewports_visible_rect.size
	var current_mouse_position = viewport_current.get_mouse_position()

	var zoom_factor = camera.position.z * 0.1

	if current_mouse_position.x < camera_automatic_pan_margin or current_mouse_position.x > viewport_size.x - camera_automatic_pan_margin:
		if current_mouse_position.x > viewport_size.x / 2:
			pan_direction.x = 1
		translate(Vector3(pan_direction.x * camera_pan_speed * zoom_factor * delta, 0, 0))
	
	if current_mouse_position.y < camera_automatic_pan_margin or current_mouse_position.y > viewport_size.y - camera_automatic_pan_margin:
		if current_mouse_position.y > viewport_size.y / 2:
			pan_direction.y = 1
		translate(Vector3(0, 0, pan_direction.y * camera_pan_speed * zoom_factor * delta))


func camera_base_rotate_update(delta: float) -> void:
	if !camera_can_rotate_base: return

	camera_base_rotate(delta, camera_rotation_direction)
	camera_rotation_direction *= camera_rotation_dampener

func camera_base_rotate(delta: float, dir: float) -> void:
	if !camera_can_rotate_base: return

	rotation.y += dir * camera_rotation_speed * delta

func camera_socket_rotate(delta: float, dir: float) -> void:
	if !camera_can_rotate_socket: return

	var new_rotation = camera_socket.rotation.x + dir * camera_rotation_speed * delta
	new_rotation = clamp(new_rotation, camera_socket_rotation_min, camera_socket_rotation_max)

	camera_socket.rotation.x = new_rotation


func camera_rotate_to_offset(delta: float) -> void:
	if !camera_can_rotate_with_mouse or !camera_rotating_with_mouse: return

	var mouse_offset = get_viewport().get_mouse_position() - mouse_last_position
	mouse_last_position = get_viewport().get_mouse_position()

	camera_base_rotate(delta, mouse_offset.x * camera_mouse_rotation_speed_scale)
	camera_socket_rotate(delta, mouse_offset.y * camera_mouse_rotation_speed_scale)