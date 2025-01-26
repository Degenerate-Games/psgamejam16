extends StaticBody3D

@export var health_component: HealthComponent
@export var spawner_component: SpawnerComponent
@export var store_component: StoreComponent

@onready var path = $Path3D

var path_followers = []


func _ready() -> void:
	health_component.connect("can_heal", _on_health_component_can_heal)
	spawner_component.connect("object_spawned", _on_spawner_component_object_spawned)
	store_component.connect("store_item_bought", _on_store_component_store_item_bought)


func add_path_follower(node: Node3D) -> PathFollow3D:
	var path_follower: PathFollow3D = PathFollow3D.new()
	node.get_parent().remove_child(node)
	node.global_transform = Transform3D.IDENTITY
	path_follower.add_child(node)
	path_followers.append(path_follower)
	path.add_child(path_follower)
	store_component.update_currency(1)
	return path_follower


func remove_path_follower() -> PathFollow3D:
	if path_followers.size() == 0:
		return null
	
	store_component.update_currency(-1)
	return path_followers.pop_back()


func _on_button_3d_component_pressed() -> void:
	store_component.show()


func _on_spawner_component_object_spawned(object: Node3D) -> void:
	object.hurtbox_component.set_damage_multiplier(store_component.get_upgrade_scale("Unit Damage"))
	object.speed_component.set_speed_multiplier(store_component.get_upgrade_scale("Unit Speed"))
	object.TARGET_NODE = null
	add_path_follower(object)


func _on_store_component_store_item_bought(store_item: StoreItem) -> void:
	print("Store item bought:", store_item.item.name)
	for i in store_item.get_cost():
		var path_follower = remove_path_follower()
		path_follower.queue_free()
		
	if store_item.item.name == "Spawn Rate":
		spawner_component.set_spawn_rate_multiplier(store_item.item.get_scaling())
	elif store_item.item.name == "Base Health":
		health_component.set_health_multiplier(store_item.item.get_scaling())
	elif store_item.item.name == "Base Heal Speed":
		health_component.set_heal_speed_multiplier(store_item.item.get_scaling())


func _on_health_component_can_heal() -> void:
	if path_followers.size() > 0 and health_component.is_hurt():
		var path_follower = path_followers.pop_back()
		var unit = path_follower.get_child(0)
		health_component.heal(unit.hurtbox_component.get_damage())
		path_follower.queue_free()


func _on_input_event(_camera:Node, event:InputEvent, _event_position:Vector3, _normal:Vector3, _shape_idx:int) -> void:
	if event is InputEventMouse:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			if event.is_pressed():
				get_parent().start_drag(self, get_parent().drag_mode.LEFT)
			else:
				if get_parent().drag_start_base != null and get_parent().drag_mode == get_parent().drag_mode.LEFT:
					get_parent().end_drag(self)
		elif event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
			if event.is_pressed():
				get_parent().start_drag(self, get_parent().drag_mode.RIGHT)
			else:
				if get_parent().drag_start_base != null and get_parent().drag_mode == get_parent().drag_mode.RIGHT:
					get_parent().end_drag(self)
		
