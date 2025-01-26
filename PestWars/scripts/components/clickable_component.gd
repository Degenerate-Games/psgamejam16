extends Area3D
class_name ClickableComponent

signal pressed(event: InputEvent)
signal released(event: InputEvent)

func _on_input_event(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			pressed.emit(event)
		else:
			released.emit(event)
