extends Control
class_name HueSlider

onready var line_drawer = $"../../LineDrawer"

signal hue_changed(hue)

var hue: float setget set_hue
var _focused setget set_focused


func _gui_input(event):
	if Input.is_action_pressed("click") and event is InputEventMouse:
		var position = event.position
		var tmphue = position.y / rect_size.y
		if tmphue < 0 or tmphue > 1:
			_focused = false
			return
		set_hue(tmphue)
		emit_signal("hue_changed", hue)


func set_hue(newhue):
	hue = newhue
	update()


func _draw():
	var x = rect_size.x
	var y = hue * rect_size.y
	draw_line(Vector2(0, y - 1), Vector2(x, y - 1), Color.black, 1, true)
	draw_line(Vector2(0, y), Vector2(x, y), Color.white, 1, true)
	draw_line(Vector2(0, y + 1), Vector2(x, y + 1), Color.black, 1, true)


func set_focused(focused):
	_focused = focused
