extends Node3D

enum DragMode { LEFT, RIGHT }

## An array of all the base locations in the scene. The first base in the array is the player's base, the last base is the enemy's base. The rest of the bases are neutral.
@export var base_locations: Array[StaticBody3D] = []
@export var units_parent: Node3D = self

var drag_start_base: Node3D
var drag_end_base: Node3D
var current_drag_mode: DragMode


func start_drag(drag_base: Node3D, mode: DragMode) -> void:
	drag_start_base = drag_base
	current_drag_mode = mode


func end_drag(drag_base: Node3D) -> void:
	drag_end_base = drag_base
	if drag_start_base != null and drag_end_base != null and drag_start_base != drag_end_base:
		if current_drag_mode == DragMode.LEFT:
			drag_start_base.send_units(drag_end_base, 1.0, units_parent)
		elif current_drag_mode == DragMode.RIGHT:
			drag_start_base.send_units(drag_end_base, 0.5, units_parent)
		drag_start_base = null
		drag_end_base = null
		current_drag_mode = DragMode.LEFT


func find_closest_base(unit_position: Vector3, base_group: String) -> Node3D:
	var closest_base: Node3D = null
	var closest_distance = 1e6
	for base in get_tree().get_nodes_in_group(base_group):
		var distance = unit_position.distance_to(base.global_transform.origin)
		if distance < closest_distance:
			closest_base = base
			closest_distance = distance
	return closest_base
