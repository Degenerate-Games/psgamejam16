## An RTS style camera that allows the user to pan, zoom, and rotate the camera using the mouse and keyboard.
## Requires the following actions to be defined in the InputMap:
## - camera_forward - Manually pans the camera forward.
## - camera_backward - Manually pans the camera backward.
## - camera_right - Manually pans the camera right.
## - camera_left - Manually pans the camera left.
## - camera_zoom_in - Zooms the camera in.
## - camera_zoom_out - Zooms the camera out.
## - camera_rotate_left - Manually rotates the camera around the base to the left.
## - camera_rotate_right - Manually rotates the camera around the base to the right.
## - camera_rotate - Rotates the camera around the base and socket using the mouse.

extends Node3D

@export_group("Camera Movement Settings")
## The speed at which the camera moves when the camera_forward, camera_backward, camera_right, and camera_left actions are pressed.
@export_range(0, 100, 1) var camera_manual_pan_speed: float = 20.0
## The margin in pixels from the edge of the screen at which the camera will start to automatically pan when the mouse is near the edge of the screen.
@export_range(0, 64, 4) var camera_automatic_pan_margin: int = 16
## The speed at which the camera moves when the mouse is near the edge of the screen.
@export_range(0, 20, 0.5) var camera_automatic_pan_speed: float = 12.0
## The area of the world the camera is allowed to pan in.
@export var camera_safe_pan_zone: Rect2 = Rect2(-100, -100, 200, 200)

@export_group("Camera Zoom Settings")
## The speed at which the camera zooms in and out when the camera_zoom_in and camera_zoom_out actions are pressed.
@export_range(0, 100, 1) var camera_zoom_speed: float = 40.0
## The minimum distance the camera can be from the base.
@export_range(0, 100, 1) var camera_zoom_min: float = 10.0
## The maximum distance the camera can be from the base.
@export_range(0, 100, 1) var camera_zoom_max: float = 25.0
## The dampening factor for the camera zoom speed.
@export_range(0, 2, 0.1) var camera_zoom_dampener: float = 0.9
## The minimum angle the camera can rotate around the socket.
@export_range(-360, 360, 0.1, "radians_as_degrees") var camera_zoom_min_angle: float = 15.0
## The maximum angle the camera can rotate around the socket.
@export_range(-360, 360, 0.1, "radians_as_degrees") var camera_zoom_max_angle: float = 75.0

@export_group("Camera Rotation Settings")
## The speed at which the camera rotates around the base when the camera_rotate_left and camera_rotate_right actions are pressed.
@export_range(0, TAU, 0.1) var camera_rotation_speed: float = PI / 4
## The dampening factor for the camera rotation speed.
@export_range(0, 2, 0.1) var camera_rotation_dampener: float = 0.9
## The minimum angle the camera can rotate around the socket.
@export_range(-TAU, TAU, 0.1) var camera_socket_rotation_min: float = -PI / 2
## The maximum angle the camera can rotate around the socket.
@export_range(-TAU, TAU, 0.1) var camera_socket_rotation_max: float = PI / 2
## The scale of camera_rotation_speed at which the camera rotates around the base and socket when the camera_rotate action is pressed.
@export_range(0, 1, 0.1) var camera_mouse_rotation_speed_scale: float = 0.3

@export_group("Camera Movement Flags")
## Whether or not to allow manual panning of the camera using the camera_forward, camera_backward, camera_right, and camera_left actions.
@export var camera_can_manual_pan: bool = true
## Whether or not to allow automatic panning of the camera when the mouse is near the edge of the screen.
@export var camera_can_automatic_pan: bool = true
## Whether or not to allow zooming the camera in and out using the camera_zoom_in and camera_zoom_out actions.
@export var camera_can_zoom: bool = true
## Whether or not to allow rotating the camera around the base using the camera_rotate_left and camera_rotate_right actions or the camera_rotate action.
@export var camera_can_rotate_base: bool = true
## Whether or not to allow rotating the camera around the socket using the camera_rotate action.
@export var camera_can_rotate_socket: bool = true
## Whether or not to allow rotating the camera around the base and socket using the mouse.
@export var camera_can_rotate_with_mouse: bool = true
## Whether ot not to rotate the camera around the socket when zooming in and out.
@export var camera_use_adaptive_zoom: bool = true

var camera_zoom_direction: float = 0.0
var camera_rotation_direction: float = 0.0
var camera_rotating_with_mouse: bool = false
var mouse_last_position: Vector2 = Vector2.ZERO

@onready var camera_socket = $CameraSocket
@onready var camera = $CameraSocket/Camera3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera_manual_pan(delta)
	camera_automatic_pan(delta)
	camera_base_rotate_update(delta)
	camera_rotate_with_mouse(delta)
	camera_zoom_update(delta)


# Catches any input events that are not handled by the InputMap.
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


# Pans the camera manually using the camera_forward, camera_backward, camera_right, and camera_left actions.
func camera_manual_pan(delta: float) -> void:
	if !camera_can_manual_pan:
		return
	var direction: Vector3 = Vector3.ZERO

	if Input.is_action_pressed("camera_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("camera_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("camera_right"):
		direction += transform.basis.x
	if Input.is_action_pressed("camera_left"):
		direction -= transform.basis.x

	var new_position = position + direction.normalized() * camera_manual_pan_speed * delta
	new_position.x = clamp(new_position.x, camera_safe_pan_zone.position.x, camera_safe_pan_zone.position.x + camera_safe_pan_zone.size.x)
	new_position.z = clamp(new_position.z, camera_safe_pan_zone.position.y, camera_safe_pan_zone.position.y + camera_safe_pan_zone.size.y)
	position = new_position


# Zooms the camera in and out based on the value of camera_zoom_speed.
func camera_zoom_update(delta: float) -> void:
	if !camera_can_zoom:
		return

	var new_zoom: float = camera.position.z + camera_zoom_direction * camera_zoom_speed * delta
	new_zoom = clamp(new_zoom, camera_zoom_min, camera_zoom_max)
	camera.position.z = new_zoom
	if camera_use_adaptive_zoom:
		camera_socket.rotation.x = lerp(camera_zoom_min_angle, camera_zoom_max_angle, inverse_lerp(camera_zoom_min, camera_zoom_max, new_zoom))

	camera_zoom_direction *= camera_zoom_dampener


# Pans the camera automatically when the mouse is near the edge of the screen.
func camera_automatic_pan(delta: float) -> void:
	if !camera_can_automatic_pan:
		return

	var viewport_current = get_viewport()
	var pan_direction = Vector2(-1, -1)
	var viewports_visible_rect = Rect2i(viewport_current.get_visible_rect())
	var viewport_size = viewports_visible_rect.size
	var current_mouse_position = viewport_current.get_mouse_position()

	var zoom_factor = camera.position.z * 0.1

	if current_mouse_position.x < camera_automatic_pan_margin or current_mouse_position.x > viewport_size.x - camera_automatic_pan_margin:
		if current_mouse_position.x > viewport_size.x / 2:
			pan_direction.x = 1
		translate(Vector3(pan_direction.x * camera_automatic_pan_speed * zoom_factor * delta, 0, 0))

	if current_mouse_position.y < camera_automatic_pan_margin or current_mouse_position.y > viewport_size.y - camera_automatic_pan_margin:
		if current_mouse_position.y > viewport_size.y / 2:
			pan_direction.y = 1
		translate(Vector3(0, 0, pan_direction.y * camera_automatic_pan_speed * zoom_factor * delta))


# Updates the camera rotation around the base based on the value of camera_rotation_direction.
func camera_base_rotate_update(delta: float) -> void:
	if !camera_can_rotate_base:
		return

	camera_base_rotate(delta, camera_rotation_direction)
	camera_rotation_direction *= camera_rotation_dampener


# Rotates the camera around the base.
func camera_base_rotate(delta: float, dir: float) -> void:
	if !camera_can_rotate_base:
		return

	rotation.y += dir * camera_rotation_speed * delta


# Rotates the camera around the socket.
func camera_socket_rotate(delta: float, dir: float) -> void:
	if !camera_can_rotate_socket:
		return

	var new_rotation = camera_socket.rotation.x + dir * camera_rotation_speed * delta
	new_rotation = clamp(new_rotation, camera_socket_rotation_min, camera_socket_rotation_max)

	camera_socket.rotation.x = new_rotation


# Rotates the camera around the base and socket using the mouse.
func camera_rotate_with_mouse(delta: float) -> void:
	if !camera_can_rotate_with_mouse or !camera_rotating_with_mouse:
		return

	var mouse_offset = get_viewport().get_mouse_position() - mouse_last_position
	mouse_last_position = get_viewport().get_mouse_position()

	camera_base_rotate(delta, mouse_offset.x * camera_mouse_rotation_speed_scale)
	camera_socket_rotate(delta, mouse_offset.y * camera_mouse_rotation_speed_scale)
