extends Node3D

enum drag_mode { LEFT, RIGHT }

@export var base_locations: Array[StaticBody3D] = []
@export var units_parent: Node3D = self

var drag_start_base: Node3D
var drag_end_base: Node3D
var current_drag_mode: drag_mode


func start_drag(drag_base: Node3D, mode: drag_mode) -> void:
	drag_start_base = drag_base
	current_drag_mode = mode


func end_drag(drag_base: Node3D) -> void:
	drag_end_base = drag_base
	if drag_start_base != null and drag_end_base != null and drag_start_base != drag_end_base:
		if current_drag_mode == drag_mode.LEFT:
			drag_start_base.send_units(drag_end_base, 1.0, units_parent)
		elif current_drag_mode == drag_mode.RIGHT:
			drag_start_base.send_units(drag_end_base, 0.5, units_parent)
		drag_start_base = null
		drag_end_base = null
		current_drag_mode = drag_mode.LEFT
