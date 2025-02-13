class_name StoreComponent
extends PanelContainer

signal store_item_bought(store_item: StoreItem)

@export_group("Store Labels")
@export var store_name: String
@export var currency: String
@export var current_currency: int
@export var maximum_purchases: int
@export var store_items: Array[StoreItem]

var current_purchases: int = 0

@onready var store_name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/StoreNameLabel
@onready var currency_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VFlowContainer/CurrencyNameLabel
@onready var current_currency_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VFlowContainer/CurrencyAmountLabel
@onready var store_items_container: GridContainer = $MarginContainer/VBoxContainer/GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	store_name_label.text = store_name
	currency_label.text = currency
	current_currency_label.text = str(current_currency)
	for store_item in store_items:
		var store_item_button = Button.new()
		store_item_button.text = store_item.item.name
		store_item_button.disabled = true
		store_item_button.connect("pressed", _on_store_item_button_pressed.bind(store_item))
		store_items_container.add_child(store_item_button)

		var store_item_level_center_container = CenterContainer.new()
		var store_item_level_label = Label.new()
		store_item_level_label.text = str(store_item.item.current_level)
		store_item_level_center_container.add_child(store_item_level_label)
		store_items_container.add_child(store_item_level_center_container)

		var store_item_cost_center_container = CenterContainer.new()
		var store_item_cost_label = Label.new()
		store_item_cost_label.text = str(store_item.get_cost())
		store_item_cost_center_container.add_child(store_item_cost_label)
		store_items_container.add_child(store_item_cost_center_container)

		store_item.item_name_button = store_item_button
		store_item.item_level_label = store_item_level_label
		store_item.item_cost_label = store_item_cost_label

	hide()

func _process(_delta: float) -> void:
	if current_purchases >= maximum_purchases:
		for store_item in store_items:
			store_item.item_name_button.disabled = true


func _on_close_button_pressed() -> void:
	hide()


func _on_store_item_button_pressed(store_item: StoreItem) -> void:
	if current_currency < store_item.get_cost() or store_item.is_max_level():
		return
	store_item_bought.emit(store_item)
	store_item.buy()
	current_purchases += 1


func update_currency(amount: int) -> void:
	current_currency += amount
	current_currency_label.text = str(current_currency)

	for store_item in store_items:
		if current_currency >= store_item.get_cost() and !store_item.is_max_level() and current_purchases < maximum_purchases:
			store_item.item_name_button.disabled = false
		else:
			store_item.item_name_button.disabled = true


func get_upgrade(upgrade_name: String) -> Upgrade:
	for store_item in store_items:
		if store_item.item.name == upgrade_name:
			return store_item.item
	return null


func get_upgrade_scale(upgrade_name: String) -> float:
	var upgrade = get_upgrade(upgrade_name)
	if upgrade != null:
		return upgrade.get_scaling()
	return -1.0
