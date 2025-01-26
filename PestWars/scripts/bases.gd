extends Node3D

enum drag_mode { LEFT, RIGHT }

@export var base_locations: Array[StaticBody3D] = []

var drag_start_base: Node3D
var drag_end_base: Node3D
var current_drag_mode: drag_mode

func start_drag(drag_base: Node3D, mode: drag_mode) -> void:
	drag_start_base = drag_base
	current_drag_mode = mode

func end_drag(drag_base: Node3D) -> void:
	drag_end_base = drag_base
	if drag_start_base != null and drag_end_base != null:
		if current_drag_mode == drag_mode.LEFT:
			drag_start_base.send_units(drag_end_base, 1.0)
		elif current_drag_mode == drag_mode.RIGHT:
			drag_end_base.send_units(drag_start_base, 0.5)
		drag_start_base = null
		drag_end_base = null
		current_drag_mode = drag_mode.LEFT
