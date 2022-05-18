extends Control
class_name ColorSelect

var color : Color setget set_color

onready var shader_holder := $ShaderHolder

signal color_changed(color)

func set_color(newcolor):
	color = newcolor
	shader_holder.material.set_shader_param("hue", color.h)
	update()

func apply_hue(newhue):
	self.color.h = newhue


func _gui_input(event):
	if event is InputEventMouseButton:
		var position = event.position
		var saturation = position.x / rect_size.x
		var value = 1 - (position.y / rect_size.y)
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
