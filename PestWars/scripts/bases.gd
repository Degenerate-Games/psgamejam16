extends Node3D

enum DragMode { LEFT, RIGHT }

## An array of all the bases in the scene. By convention the first base in the array is the player's base, the last base is the enemy's base and the rest of the bases are neutral.
@export var bases: Array[Base] = []
@export var units_parent: Node3D = self

var drag_start_base: Node3D
var drag_end_base: Node3D
var current_drag_mode: DragMode

var bot_base_scene: PackedScene = preload("res://scenes/structures/bot_base.tscn")
var enemy_base_scene: PackedScene = preload("res://scenes/structures/enemy_base.tscn")
var neutral_base_scene: PackedScene = preload("res://scenes/structures/neutral_base.tscn")


func _ready() -> void:
	for base in bases:
		base.connect("base_destroyed", _on_base_destroyed)


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
		if is_zero_approx(distance):
			continue
		if distance < closest_distance:
			closest_base = base
			closest_distance = distance
	if closest_base == null:
		return self
	return closest_base


func _on_base_destroyed(base: Node3D, attacker_team: String) -> void:
	var base_index = bases.find(base)
	if base_index != -1:
		if base.get_groups().has("neutral_base"):
			var new_base = null
			if attacker_team == "bot":
				new_base = bot_base_scene.instantiate()
			elif attacker_team == "bug":
				new_base = enemy_base_scene.instantiate()

			add_child(new_base)
			new_base.global_transform.origin = base.global_transform.origin
			bases[base_index] = new_base
		else:
			var new_base = neutral_base_scene.instantiate()
			add_child(new_base)
			new_base.global_transform = base.global_transform
			bases[base_index] = new_base

		base.queue_free()
		bases[base_index].connect("base_destroyed", _on_base_destroyed)
		for unit in get_tree().get_nodes_in_group("units"):
			if unit.target_node == base:
				unit.set_target(bases[base_index])
