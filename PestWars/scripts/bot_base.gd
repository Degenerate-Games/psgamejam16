extends Base


@export var store_component: StoreComponent


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	store_component.connect("store_item_bought", _on_store_component_store_item_bought)


func add_path_follower(node: Node3D) -> PathFollow3D:
	var follower = super(node)
	store_component.update_currency(1)
	return follower

func remove_path_follower() -> PathFollow3D:
	var follower = super()
	store_component.update_currency(-1)
	return follower


func _on_button_3d_component_pressed() -> void:
	store_component.show()


func _on_spawner_component_object_spawned(object: Node3D) -> void:
	super(object)
	object.hurtbox_component.set_damage_multiplier(store_component.get_upgrade_scale("Unit Damage"))
	object.speed_component.set_speed_multiplier(store_component.get_upgrade_scale("Unit Speed"))


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