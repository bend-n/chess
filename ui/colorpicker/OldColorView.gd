extends ColorRect
class_name OldColorView

signal color_changed(color)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		emit_signal("color_changed", color)
