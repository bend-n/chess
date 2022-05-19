extends Control
class_name HueSlider

signal hue_changed(hue)

var hue: float setget set_hue


func _gui_input(event):
	if Input.is_action_pressed("click") and event is InputEventMouse:
		var position = event.position
		var tmphue = clamp(position.y / rect_size.y, 0, 1)
		set_hue(tmphue)
		emit_signal("hue_changed", hue)


func set_hue(newhue):
	if newhue != hue:
		hue = newhue
		update()


func _draw():
	var x = rect_size.x
	var y = hue * rect_size.y
	draw_line(Vector2(0, y - 1), Vector2(x, y - 1), Color.black, 1, true)
	draw_line(Vector2(0, y), Vector2(x, y), Color.white, 1, true)
	draw_line(Vector2(0, y + 1), Vector2(x, y + 1), Color.black, 1, true)
