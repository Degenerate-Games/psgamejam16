extends Control


func set_label_text(text: String) -> void:
	$VBoxContainer/Label.text = text


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	queue_free()


func _on_button_2_pressed() -> void:
	get_tree().reload_current_scene()
	queue_free()
