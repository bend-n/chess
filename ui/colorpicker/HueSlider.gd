extends Control
class_name HueSlider

signal hue_changed(hue)

var hue: float = 0


func _gui_input(event: InputEvent) -> void:
	if Input.is_action_pressed("click") and event is InputEventMouse:
		var position: Vector2 = event.position
		set_hue(clamp(position.y / rect_size.y, 0, 1))
		emit_signal("hue_changed", hue)


func set_hue(nh: float) -> void:
	if nh != hue:
		hue = nh
		update()


func _draw() -> void:
	var y := hue * rect_size.y
	var drawclr := Color.from_hsv(wrapf(hue + .5, 0, 1), 1, 1, 1)
	draw_line(Vector2(0, y), Vector2(rect_size.x, y), drawclr, 1, true)
