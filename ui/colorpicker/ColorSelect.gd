extends Control
class_name ColorSelect

var color: Color setget set_color

var _focused := false setget set_focused

onready var shader_holder := $ShaderHolder

signal color_changed(color)


func set_color(newcolor):
	if newcolor != color:
		color = newcolor
		shader_holder.material.set_shader_param("hue", color.h)
		update()


func apply_hue(newhue):
	self.color.h = newhue


func _gui_input(event):
	if _focused and Input.is_action_pressed("click") and event is InputEventMouse:
		var position = event.position
		var saturation = position.x / rect_size.x
		var value = 1 - (position.y / rect_size.y)
		if saturation > 1 or saturation < 0 or value > 1 or value < 0:
			_focused = false
			return
		set_color(Color.from_hsv(color.h, saturation, value))
		update()
		emit_signal("color_changed", color)


func _draw():
	var vlinex = color.s * rect_size.x
	var vliney = rect_size.y

	draw_line(Vector2(vlinex - 1, 0), Vector2(vlinex - 1, vliney), Color.black)
	draw_line(Vector2(vlinex, 0), Vector2(vlinex, vliney), Color.white)
	draw_line(Vector2(vlinex + 1, 0), Vector2(vlinex + 1, vliney), Color.black)

	var hlinex = rect_size.x
	var hliney = rect_size.y - color.v * rect_size.y

	draw_line(Vector2(0, hliney - 1), Vector2(hlinex, hliney - 1), Color.black)
	draw_line(Vector2(0, hliney), Vector2(hlinex, hliney), Color.white)
	draw_line(Vector2(0, hliney + 1), Vector2(hlinex, hliney + 1), Color.black)


func set_focused(focused):
	_focused = focused
