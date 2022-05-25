extends Control
class_name HueSlider

signal color_changed(color)

var color: Color setget set_color


func _gui_input(event):
	if Input.is_action_pressed("click") and event is InputEventMouse:
		var position = event.position
		var tmphue = clamp(position.y / rect_size.y, 0, 1)
		set_color(Color.from_hsv(tmphue, color.s, color.v))
		emit_signal("color_changed", color)


func set_color(newcolor):
	if newcolor != color:
		color = newcolor
		update()


func _draw():
	var x = rect_size.x
	var y = color.h * rect_size.y
	draw_line(Vector2(0, y - 1), Vector2(x, y - 1), Color.black, 1, true)
	draw_line(Vector2(0, y), Vector2(x, y), Color.white, 1, true)
	draw_line(Vector2(0, y + 1), Vector2(x, y + 1), Color.black, 1, true)
