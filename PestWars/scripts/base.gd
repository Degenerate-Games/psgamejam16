class_name Base
extends StaticBody3D

signal base_destroyed(base: Node3D, attacker_team: String)

@export var health_component: HealthComponent
@export var spawner_component: SpawnerComponent

var path_followers = []

@onready var path = $Path3D


func add_path_follower(node: Node3D) -> PathFollow3D:
	var path_follower: PathFollow3D = PathFollow3D.new()
	node.global_transform = Transform3D.IDENTITY
	node.reparent(path_follower, true)
	path_followers.append(path_follower)
	path.add_child(path_follower)
	return path_follower


func remove_path_follower() -> PathFollow3D:
	if path_followers.size() == 0:
		return null

	return path_followers.pop_back()


func send_units(target: Node3D, percentage: float, new_parent: Node3D) -> void:
	var unit_count = path_followers.size()
	if unit_count == 0:
		return
	if new_parent == null:
		new_parent = get_tree().get_first_node_in_group("base_controller").units_parent
	for i in range(floor(unit_count * percentage)):
		remove_path_follower().queue_free()
		var unit = spawner_component.spawn_no_signal()
		unit.reparent(new_parent, true)
		unit.set_target(target)
		unit.rotate_y(randf_range(0, TAU))


func _on_spawner_component_object_spawned(object: Node3D) -> void:
	add_path_follower(object)


func _on_health_component_can_heal() -> void:
	if path_followers.size() > 0 and health_component.is_hurt():
		var path_follower = path_followers.pop_back()
		var unit = path_follower.get_child(0)
		health_component.heal(unit.hurtbox_component.get_damage())
		path_follower.queue_free()


func _on_clickable_component_pressed(event: InputEvent) -> void:
	var base_controller = get_tree().get_first_node_in_group("base_controller")
	if event.button_index == MOUSE_BUTTON_LEFT:
		base_controller.start_drag(self, base_controller.DragMode.LEFT)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		base_controller.start_drag(self, base_controller.DragMode.RIGHT)


func _on_clickable_component_released(event: InputEvent) -> void:
	var base_controller = get_tree().get_first_node_in_group("base_controller")
	if event.button_index == MOUSE_BUTTON_LEFT:
		if base_controller.drag_start_base != null and base_controller.current_drag_mode == base_controller.DragMode.LEFT:
			base_controller.end_drag(self)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if base_controller.drag_start_base != null and base_controller.current_drag_mode == base_controller.DragMode.RIGHT:
			base_controller.end_drag(self)


func _on_health_component_died(attacker_team: String) -> void:
	base_destroyed.emit(self, attacker_team)
