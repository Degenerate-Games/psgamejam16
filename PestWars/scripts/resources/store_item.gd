class_name StoreItem
extends Resource

@export var item: Upgrade
@export var base_cost: int
@export var cost_multiplier: float

var item_name_button: Button
var item_level_label: Label
var item_cost_label: Label


func get_cost() -> int:
	return get_cost_at_level(item.current_level)


func get_cost_at_level(level: int) -> int:
	if level <= 0 or level > item.max_level:
		return -1
	return round(base_cost * pow(cost_multiplier, level - 1))


func buy() -> void:
	if item.upgrade():
		item_level_label.text = str(item.current_level)
		item_cost_label.text = str(get_cost())
	else:
		item_name_button.disabled = true
