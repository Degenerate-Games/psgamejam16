extends Control


enum State {MAIN, CONTROLS, GOAL, STORE}

var current_state: State = State.MAIN

@onready var main_container: VBoxContainer = $Control/VBoxContainer
@onready var margin_container: Control = $Control/MarginContainer
@onready var controls: TextureRect = $Control/TextureRect
@onready var goal: TextureRect = $Control/TextureRect2
@onready var store: TextureRect = $Control/TextureRect3

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/demo_level.tscn")


func _on_button_2_pressed() -> void:
	main_container.hide()
	controls.show()
	margin_container.show()
	current_state = State.CONTROLS


func _on_next_pressed() -> void:
	if current_state == State.CONTROLS:
		controls.hide()
		goal.show()
		current_state = State.GOAL
	elif current_state == State.GOAL:
		goal.hide()
		store.show()
		current_state = State.STORE
	elif current_state == State.STORE:
		store.hide()
		margin_container.hide()
		main_container.show()
		current_state = State.MAIN


func _on_previous_pressed() -> void:
	if current_state == State.CONTROLS:
		margin_container.hide()
		controls.hide()
		main_container.show()
		current_state = State.MAIN
	elif current_state == State.GOAL:
		goal.hide()
		controls.show()
		current_state = State.CONTROLS
	elif current_state == State.STORE:
		store.hide()
		goal.show()
		current_state = State.GOAL