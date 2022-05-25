extends Control
class_name ColorSelect

var color: Color setget set_color

onready var shader_holder := $ShaderHolder

signal color_changed(color)


func set_color(newcolor):
	if newcolor != color:
		color = newcolor
		shader_holder.material.set_shader_param("hue", color.h)
		update()


func _gui_input(event):
	if Input.is_action_pressed("click") and event is InputEventMouse:
		var position = event.position
		var saturation = clamp(position.x / rect_size.x, 0, 1)
		var value = clamp(1 - (position.y / rect_size.y), 0, 1)
		set_color(Color.from_hsv(color.h, saturation, value))
		update()
		emit_signal("color_changed", color)


func _draw():
	var draw_color = color.inverted()

	var vlinex = color.s * rect_size.x
	var vliney = rect_size.y

	draw_line(Vector2(vlinex, 0), Vector2(vlinex, vliney), draw_color)

	var hlinex = rect_size.x
	var hliney = rect_size.y - color.v * rect_size.y

	draw_line(Vector2(0, hliney), Vector2(hlinex, hliney), draw_color)
