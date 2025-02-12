class_name Button3DComponent
extends StaticBody3D

signal pressed

@export var button: Button


func _on_button_3d_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			button.emit_signal("pressed")
			button.set_pressed_no_signal(true)
		else:
			button.set_pressed_no_signal(false)


func _on_button_pressed():
	pressed.emit()
