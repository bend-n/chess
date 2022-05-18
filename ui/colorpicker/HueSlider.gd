extends Control
class_name HueSlider

onready var line_drawer = $"../../LineDrawer"

signal hue_changed(hue)

var hue :float setget set_hue

func _gui_input(event):
	if event is InputEventMouseButton:
		var position = event.position
		set_hue(position.y / rect_size.y)
		emit_signal("hue_changed", hue)

func set_hue(newhue):
	hue = newhue
	update()

func _draw():
	var x = rect_size.x 
	var y = hue * rect_size.y
	draw_line(Vector2(0, y - 1), Vector2(x, y -1), Color.black, 1, true)
	draw_line(Vector2(0, y), Vector2(x, y), Color.white, 1, true)
	draw_line(Vector2(0, y + 1), Vector2(x, y + 1), Color.black, 1, true)
