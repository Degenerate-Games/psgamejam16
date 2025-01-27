extends StaticBody3D
class_name Base

@export var health_component: HealthComponent
@export var spawner_component: SpawnerComponent

@onready var path = $Path3D

var path_followers = []


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
	for i in range(floor(unit_count * percentage)):
		remove_path_follower().queue_free()
		var unit = spawner_component.spawn_no_signal()
		unit.reparent(new_parent, true)
		unit.set_target(target)


func _on_spawner_component_object_spawned(object: Node3D) -> void:
	add_path_follower(object)


func _on_health_component_can_heal() -> void:
	if path_followers.size() > 0 and health_component.is_hurt():
		var path_follower = path_followers.pop_back()
		var unit = path_follower.get_child(0)
		health_component.heal(unit.hurtbox_component.get_damage())
		path_follower.queue_free()


func _on_clickable_component_pressed(event: InputEvent) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		get_parent().start_drag(self, get_parent().drag_mode.LEFT)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		get_parent().start_drag(self, get_parent().drag_mode.RIGHT)


func _on_clickable_component_released(event: InputEvent) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if (
			get_parent().drag_start_base != null
			and get_parent().current_drag_mode == get_parent().drag_mode.LEFT
		):
			get_parent().end_drag(self)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if (
			get_parent().drag_start_base != null
			and get_parent().current_drag_mode == get_parent().drag_mode.RIGHT
		):
			get_parent().end_drag(self)
